import gleam/int
import gleam/io
import argv
import life/board

pub fn main() {
  case argv.load().arguments {
    [arg_key, arg_value] -> {
      case arg_key {
        "--generations" | "-g" -> {
          let generations = case int.parse(arg_value) {
            Ok(g) -> g
            Error(_) -> 10
          }

          board.random(25, 25)
          |> board.next_generation
          |> board.next_generation
          |> board.play(generations)
        }
        _ -> render_usage()
      }
    }
    _ -> render_usage()
  }
}

pub fn render_usage() {
  io.println("Usage: life [--generations | -g] <number of generations>")
}
