import gleam/io
import gleam/list
import gleam/dict
import gleam/string

pub fn main() {
  let board =
    new_board(5, 5)
    |> set_cell(row: 1, col: 2, state: Alive)
    |> set_cell(row: 2, col: 2, state: Alive)
    |> set_cell(row: 3, col: 2, state: Alive)

  render_board(
    board
    |> next_generation,
  )
}

pub type CellState {
  Dead
  Alive
}

pub type Cell {
  Cell(state: CellState, col: Int, row: Int)
}

pub type Board {
  Board(grid: dict.Dict(#(Int, Int), Cell), height: Int, width: Int)
}

pub fn new_board(width: Int, height: Int) -> Board {
  let grid =
    list.range(0, width * height)
    |> list.map(fn(i) {
      let x = i % width
      let y = i / height

      #(#(x, y), Cell(col: x, row: y, state: Dead))
    })
    |> dict.from_list

  Board(grid, height, width)
}

pub fn get_cell(board board: Board, row row: Int, col col: Int) -> Cell {
  case dict.get(board.grid, #(row, col)) {
    Ok(cell) -> cell
    _ -> Cell(state: Dead, col: col, row: row)
  }
}

pub fn set_cell(
  board board: Board,
  col col: Int,
  row row: Int,
  state state: CellState,
) -> Board {
  let new_grid =
    dict.update(board.grid, #(row, col), fn(_) {
      Cell(col: col, row: row, state: state)
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
      let cell = get_cell(board, y, x)

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
  row row: Int,
  col col: Int,
) -> List(Cell) {
  let neigbours = [
    #(row - 1, col - 1),
    #(row, col - 1),
    #(row + 1, col - 1),
    #(row - 1, col),
    #(row + 1, col),
    #(row - 1, col + 1),
    #(row, col + 1),
    #(row + 1, col + 1),
  ]

  neigbours
  |> list.map(fn(tuple) { get_cell(board, tuple.0, tuple.1) })
}

pub fn count_live_neighbours(
  board board: Board,
  row row: Int,
  col col: Int,
) -> Int {
  board
  |> get_neighbours(row: row, col: col)
  |> list.filter(is_alive)
  |> list.length
}

pub fn next_generation(board: Board) -> Board {
  let range_y = list.range(0, board.height - 1)
  let range_x = list.range(0, board.width - 1)

  let new_grid =
    range_y
    |> list.map(fn(row) {
      range_x
      |> list.map(fn(col) {
        let cell = get_cell(board, row, col)

        let live_neighbours =
          board
          |> count_live_neighbours(row, col)

        case #(cell.state, live_neighbours) {
          #(Alive, 2) -> cell
          #(Alive, 3) -> cell
          #(Alive, _) -> Cell(col: col, row: row, state: Dead)
          #(Dead, 3) -> Cell(col: col, row: row, state: Alive)
          #(Dead, _) -> cell
        }
      })
    })
    |> list.flatten
    |> list.map(fn(cell) { #(#(cell.row, cell.col), cell) })
    |> dict.from_list

  Board(..board, grid: new_grid)
}

pub fn is_alive(cell: Cell) -> Bool {
  cell.state == Alive
}
