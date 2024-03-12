import board.{Alive, Position}

pub fn main() {
  let new_board =
    board.new(5, 5)
    |> board.set_cell(Position(row: 1, col: 2), state: Alive)
    |> board.set_cell(Position(row: 2, col: 2), state: Alive)
    |> board.set_cell(Position(row: 3, col: 2), state: Alive)

  new_board
  |> board.next_generation
  |> board.next_generation
  |> board.play(10)
}
