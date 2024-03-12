import gleam/io
import gleam/list
import gleam/dict
import gleam/string

pub fn main() {
  let board =
    new_board(5, 5)
    |> set_cell(Position(row: 1, col: 2), state: Alive)
    |> set_cell(Position(row: 2, col: 2), state: Alive)
    |> set_cell(Position(row: 3, col: 2), state: Alive)

  board
  |> next_generation
  |> next_generation
  |> render_board
}

pub type CellState {
  Dead
  Alive
}

pub type Position {
  Position(row: Int, col: Int)
}

pub type Cell {
  Cell(state: CellState, position: Position)
}

pub type Board {
  Board(grid: dict.Dict(Position, Cell), height: Int, width: Int)
}

pub fn new_board(width: Int, height: Int) -> Board {
  let grid =
    list.range(0, width * height)
    |> list.map(fn(i) {
      let position = Position(row: i % width, col: i / height)

      #(position, Cell(state: Dead, position: position))
    })
    |> dict.from_list

  Board(grid, height, width)
}

pub fn get_cell(board board: Board, position position: Position) -> Cell {
  case dict.get(board.grid, position) {
    Ok(cell) -> cell
    _ -> Cell(state: Dead, position: position)
  }
}

pub fn set_cell(
  board board: Board,
  position position: Position,
  state state: CellState,
) -> Board {
  let new_grid =
    dict.update(board.grid, position, fn(_) {
      Cell(position: position, state: state)
    })

  Board(..board, grid: new_grid)
}

const dead_cell = "⬛"

const live_cell = "⬜"

pub fn render_board(board: Board) {
  let range_y = list.range(0, board.height - 1)
  let range_x = list.range(0, board.width - 1)

  range_y
  |> list.map(fn(y) {
    range_x
    |> list.map(fn(x) {
      let cell = get_cell(board, Position(row: y, col: x))

      case cell.state {
        Alive -> live_cell
        _ -> dead_cell
      }
    })
  })
  |> list.map(join_list)
  |> list.map(io.println)
}

pub fn join_list(chars: List(String)) -> String {
  chars
  |> list.fold("", string.append)
}

pub fn get_neighbours(
  board board: Board,
  position position: Position,
) -> List(Cell) {
  let Position(row, col) = position
  let neigbours = [
    Position(row - 1, col - 1),
    Position(row - 1, col),
    Position(row - 1, col + 1),
    Position(row, col - 1),
    Position(row, col + 1),
    Position(row + 1, col - 1),
    Position(row + 1, col),
    Position(row + 1, col + 1),
  ]

  neigbours
  |> list.map(get_cell(board, _))
}

pub fn count_live_neighbours(
  board board: Board,
  position position: Position,
) -> Int {
  board
  |> get_neighbours(position)
  |> list.filter(is_alive)
  |> list.length
}

pub fn next_generation(board: Board) -> Board {
  let new_grid =
    board.grid
    |> dict.map_values(fn(position, cell) {
      let live_neighbours =
        board
        |> count_live_neighbours(position)

      case #(cell.state, live_neighbours) {
        #(Alive, count) ->
          case count {
            2 | 3 -> cell
            _ -> Cell(..cell, state: Dead)
          }
        #(Dead, 3) -> Cell(..cell, state: Alive)
        #(Dead, _) -> cell
      }
    })

  Board(..board, grid: new_grid)
}

pub fn is_alive(cell: Cell) -> Bool {
  cell.state == Alive
}
