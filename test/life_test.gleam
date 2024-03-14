import gleeunit
import gleeunit/should
import life/board
import life/matrix.{Position}

pub fn main() {
  gleeunit.main()
}

pub fn alernating_pattern_test() {
  let board_1 =
    board.new(3, 3)
    |> board.toggle(Position(y: 0, x: 1))
    |> board.toggle(Position(y: 1, x: 1))
    |> board.toggle(Position(y: 2, x: 1))

  let board_2 =
    board.new(3, 3)
    |> board.toggle(Position(y: 1, x: 0))
    |> board.toggle(Position(y: 1, x: 1))
    |> board.toggle(Position(y: 1, x: 2))

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
    |> board.toggle(Position(y: 0, x: 0))
    |> board.toggle(Position(y: 0, x: 1))
    |> board.toggle(Position(y: 1, x: 0))
    |> board.toggle(Position(y: 1, x: 1))

  board_1
  |> board.next_generation()
  |> should.equal(board_1)
}

pub fn from_to_seed_test() {
  let x = True
  let o = False

  let seed = [[o, x, o], [o, x, o], [o, x, o]]

  let board_1 =
    board.new(3, 3)
    |> board.toggle(Position(y: 0, x: 1))
    |> board.toggle(Position(y: 1, x: 1))
    |> board.toggle(Position(y: 2, x: 1))

  let board_2 =
    seed
    |> board.from_seed

  board_2
  |> shoud_eq_string(board_1)

  // 2 generations should return to the original board
  board_2
  |> board.next_generation
  |> board.next_generation
  |> shoud_eq_string(board_1)

  board_1
  |> board.to_seed
  |> should.equal(seed)
}

pub fn shoud_eq_string(a: board.Board, b: board.Board) {
  should.equal(
    a
      |> board.to_string,
    b
      |> board.to_string,
  )
}
