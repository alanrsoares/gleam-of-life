import gleam/dict
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import life/matrix.{Position}

/// A cell can be dead or alive
/// 
pub type IsAlive =
  Bool

/// A board is a grid of cells
/// 
pub type Board {
  Board(grid: dict.Dict(matrix.Position, IsAlive), height: Int, width: Int)
}

pub const dead_cell = "⬛"

pub const live_cell = "⬜"

/// Create a new board with a cell initialiser
/// 
pub fn new_with(
  width width: Int,
  height height: Int,
  with fun: fn() -> IsAlive,
) -> Board {
  let grid =
    matrix.new_with(height, width, fun)
    |> matrix.to_dict

  Board(grid, height, width)
}

/// Create a new board
/// 
pub fn new(width width: Int, height height: Int) -> Board {
  new_with(width, height, fn() { False })
}

/// Create a new board with a random state
/// 
pub fn random(width width: Int, height height: Int) -> Board {
  new_with(width, height, fn() {
    case int.random(5) {
      0 -> True
      _ -> False
    }
  })
}

/// Create a new board from a seed matrix
///
pub fn from_seed(rows: matrix.Matrix(IsAlive)) -> Board {
  let height = list.length(rows)
  let width = case list.first(rows) {
    Ok(row) -> list.length(row)
    _ -> panic as "Seed must have at least one row"
  }

  let grid =
    rows
    |> matrix.to_dict

  Board(grid, height, width)
}

/// Convert the board to a seed matrix
/// 
pub fn to_seed(board: Board) -> matrix.Matrix(IsAlive) {
  let rows = list.range(0, board.height - 1)
  let cols = list.range(0, board.width - 1)

  rows
  |> list.map(fn(y) {
    cols
    |> list.map(fn(x) {
      board
      |> get(Position(y, x))
    })
  })
}

/// Get the state of a cell
/// 
pub fn get(board board: Board, position position: matrix.Position) -> IsAlive {
  case dict.get(board.grid, position) {
    Ok(cell) -> cell
    _ -> False
  }
}

/// Set the state of a cell
/// 
pub fn set(
  board board: Board,
  position position: matrix.Position,
  state state: IsAlive,
) -> Board {
  let next_grid =
    board.grid
    |> dict.update(position, fn(_) { state })

  Board(..board, grid: next_grid)
}

/// Toggle the state of a cell
/// 
pub fn toggle(board board: Board, position position: matrix.Position) -> Board {
  set(board, position, case get(board, position) {
    True -> False
    _ -> True
  })
}

/// Get the neighbouring cells of a cell
/// 
pub fn neighbours(
  board board: Board,
  position position: matrix.Position,
) -> List(IsAlive) {
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
  position position: matrix.Position,
) -> Int {
  board
  |> neighbours(position)
  |> list.filter(is_alive)
  |> list.length
}

/// Generate the next generation of the board
/// 
pub fn next_generation(board: Board) -> Board {
  let next_grid =
    board.grid
    |> dict.map_values(fn(position, is_alive) {
      let live_neighbours =
        board
        |> count_live_neighbours(position)

      case is_alive, live_neighbours {
        True, count ->
          case count {
            2 | 3 ->
              // lives on
              is_alive
            _ ->
              // dies of underpopulation or overpopulation
              False
          }
        False, count ->
          // becomes alive if it has exactly 3 live neighbours
          count == 3
      }
    })

  Board(..board, grid: next_grid)
}

/// Check if a cell is alive
/// 
pub fn is_alive(cell: IsAlive) -> IsAlive {
  cell
}

/// Convert the board to a string
/// 
pub fn to_string(board: Board) {
  let rows = list.range(0, board.height - 1)
  let cols = list.range(0, board.width - 1)

  rows
  |> list.map(fn(y) {
    cols
    |> list.map(fn(x) {
      let cell =
        board
        |> get(Position(y, x))

      case cell {
        True -> live_cell
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
