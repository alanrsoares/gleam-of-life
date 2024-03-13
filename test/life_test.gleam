import gleeunit
import gleeunit/should
import life/board.{Alive, Position}

pub fn main() {
  gleeunit.main()
}

pub fn alernating_pattern_test() {
  let board_1 =
    board.new(3, 3)
    |> board.set(Position(row: 0, col: 1), Alive)
    |> board.set(Position(row: 1, col: 1), Alive)
    |> board.set(Position(row: 2, col: 1), Alive)

  let board_2 =
    board.new(3, 3)
    |> board.set(Position(row: 1, col: 0), Alive)
    |> board.set(Position(row: 1, col: 1), Alive)
    |> board.set(Position(row: 1, col: 2), Alive)

  board_1
  |> board.next_generation()
  |> should.equal(board_2)

  board_2
  |> board.next_generation()
  |> should.equal(board_1)
}

pub fn block_pattern_test() {
  let board_1 =
    board.new(3, 3)
    |> board.set(Position(row: 0, col: 0), Alive)
    |> board.set(Position(row: 0, col: 1), Alive)
    |> board.set(Position(row: 1, col: 0), Alive)
    |> board.set(Position(row: 1, col: 1), Alive)

  board_1
  |> board.next_generation()
  |> should.equal(board_1)
}

pub fn from_seed_test() {
  let board_seed = [
    ["⬛", "⬜", "⬛"],
    ["⬛", "⬜", "⬛"],
    ["⬛", "⬜", "⬛"],
  ]

  let board_1 =
    board.new(3, 3)
    |> board.set(Position(row: 0, col: 1), Alive)
    |> board.set(Position(row: 1, col: 1), Alive)
    |> board.set(Position(row: 2, col: 1), Alive)

  let board_2 =
    board_seed
    |> board.from_seed

  board_2
  |> should.equal(board_1)

  // 2 generations should return to the original board
  board_2
  |> board.next_generation
  |> board.next_generation
  |> should.equal(board_1)

  board_1
  |> board.to_seed
  |> should.equal(board_seed)
}
