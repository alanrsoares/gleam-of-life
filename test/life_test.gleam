import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn render_grid_test() {
  1
  |> should.equal(1)
}
