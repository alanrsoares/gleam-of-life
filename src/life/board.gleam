import gleam/io
import gleam/list
import gleam/dict
import gleam/int
import gleam/string
import gleam/result
import gleam/erlang/process

/// A cell can be dead or alive
/// 
pub type CellState {
  Dead
  Alive
}

/// A position on the board
/// 
pub type Position {
  Position(row: Int, col: Int)
}

/// A board is a grid of cells
/// 
pub type Board {
  Board(grid: dict.Dict(Position, CellState), height: Int, width: Int)
}

pub const dead_cell = "⬛"

pub const live_cell = "⬜"

/// Create a new board with a cell initialiser
/// 
pub fn new_with(width: Int, height: Int, with: fn() -> CellState) -> Board {
  let grid =
    list.range(0, width * height)
    |> list.map(fn(i) {
      let position = Position(row: i % width, col: i / height)

      #(position, with())
    })
    |> dict.from_list

  Board(grid, height, width)
}

/// Create a new board
/// 
pub fn new(width: Int, height: Int) -> Board {
  new_with(width, height, fn() { Dead })
}

/// Create a new board with a random state
/// 
pub fn random(width: Int, height: Int) -> Board {
  new_with(width, height, fn() {
    case int.random(5) {
      0 -> Alive
      _ -> Dead
    }
  })
}

/// Create a new board from a seed matrix
///
pub fn from_seed(rows: List(List(String))) -> Board {
  let height = list.length(rows)
  let width = case list.first(rows) {
    Ok(row) -> list.length(row)
    _ -> panic("Seed must have at least one row")
  }

  let grid =
    list.range(0, width * height)
    |> list.map(fn(i) {
      let position = Position(row: i % width, col: i / height)

      let cell =
        rows
        |> list.at(position.row)
        |> result.unwrap([])
        |> list.at(position.col)
        |> result.unwrap("⬛")

      let cell_state = case cell {
        "⬜" -> Alive
        "⬛" -> Dead
        _ -> Dead
      }

      #(position, cell_state)
    })
    |> dict.from_list

  Board(grid, height, width)
}

/// Convert the board to a seed matrix
/// 
pub fn to_seed(board: Board) -> List(List(String)) {
  let range_y = list.range(0, board.height - 1)
  let range_x = list.range(0, board.width - 1)

  range_y
  |> list.map(fn(y) {
    range_x
    |> list.map(fn(x) {
      let cell =
        board
        |> get(Position(row: y, col: x))

      case cell {
        Alive -> "⬜"
        _ -> "⬛"
      }
    })
  })
}

/// Get the state of a cell
/// 
pub fn get(board board: Board, position position: Position) -> CellState {
  case dict.get(board.grid, position) {
    Ok(cell) -> cell
    _ -> Dead
  }
}

/// Set the state of a cell
/// 
pub fn set(
  board board: Board,
  position position: Position,
  state state: CellState,
) -> Board {
  let new_grid = dict.update(board.grid, position, fn(_) { state })

  Board(..board, grid: new_grid)
}

/// Get the neighbouring cells of a cell
/// 
pub fn neighbours(
  board board: Board,
  position position: Position,
) -> List(CellState) {
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
  |> list.map(get(board, _))
}

/// Count the number of live neighbours of a cell
/// 
pub fn count_live_neighbours(
  board board: Board,
  position position: Position,
) -> Int {
  board
  |> neighbours(position)
  |> list.filter(is_alive)
  |> list.length
}

/// Generate the next generation of the board
/// 
pub fn next_generation(board: Board) -> Board {
  let new_grid =
    board.grid
    |> dict.map_values(fn(position, cell) {
      let live_neighbours =
        board
        |> count_live_neighbours(position)

      case #(cell, live_neighbours) {
        #(Alive, count) ->
          case count {
            2 | 3 -> cell
            _ -> Dead
          }
        #(Dead, 3) -> Alive
        #(Dead, _) -> cell
      }
    })

  Board(..board, grid: new_grid)
}

/// Check if a cell is alive
/// 
pub fn is_alive(cell: CellState) -> Bool {
  cell == Alive
}

/// Convert the board to a string
/// 
pub fn to_string(board: Board) {
  let range_y = list.range(0, board.height - 1)
  let range_x = list.range(0, board.width - 1)

  range_y
  |> list.map(fn(y) {
    range_x
    |> list.map(fn(x) {
      let cell =
        board
        |> get(Position(row: y, col: x))

      case cell {
        Alive -> live_cell
        _ -> dead_cell
      }
    })
  })
  |> list.map(string.join(_, ""))
  |> string.join("\n")
}

/// Render the board to the terminal
/// 
pub fn render(board: Board) -> Nil {
  // clear the terminal
  io.print("\u{001B}[2J\u{001B}[;H")

  board
  |> to_string
  |> io.println
}

/// Play the game of life for a number of generations
/// 
pub fn play(board: Board, generations: Int) -> Nil {
  board
  |> render

  case generations {
    0 -> io.println("\nDone\n")
    _ -> {
      io.println("")
      io.println("Generations left: " <> int.to_string(generations))
      io.println("> hit Ctrl-C to stop the program")

      process.sleep(1000 / 60)

      play(next_generation(board), generations - 1)
    }
  }
}
