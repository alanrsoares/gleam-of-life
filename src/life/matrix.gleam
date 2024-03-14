import gleam/list
import gleam/dict

/// A position on the board
/// 
pub type Position {
  Position(y: Int, x: Int)
}

/// A 2D matrix of values
/// 
pub type Matrix(value) =
  List(List(value))

/// Create a matrix of the given size, with each cell set to the given value
/// 
pub fn map(
  matrix: Matrix(value),
  with fun: fn(Position, value) -> new_value,
) -> Matrix(new_value) {
  list.index_map(matrix, fn(row, y) {
    row
    |> list.index_map(fn(cell, x) { fun(Position(y, x), cell) })
  })
}

/// Convert a matrix to a dictionary of positions to values
/// 
pub fn to_dict(matrix: Matrix(value)) -> dict.Dict(Position, value) {
  matrix
  |> map(fn(pos, value) { #(pos, value) })
  |> list.flatten
  |> dict.from_list
}

pub fn new_with(
  height: Int,
  width: Int,
  with fun: fn() -> value,
) -> Matrix(value) {
  let ys = list.range(0, height)
  let xs = list.range(0, width)

  ys
  |> list.map(fn(_) {
    xs
    |> list.map(fn(_) { fun() })
  })
}
