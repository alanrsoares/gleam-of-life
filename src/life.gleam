import argv
import gleam/io
import gleam/option
import life/board
import sheen
import sheen/named

pub fn main() {
  let parse_result =
    parser()
    |> sheen.run(argv.load().arguments)

  case parse_result {
    Ok(args) -> {
      board.random(width: args.width, height: args.height)
      |> board.play(args.generations)
    }
    Error(_) -> render_help()
  }
}

fn render_help() {
  io.println(
    "Usage:

  life [--generations | -g] <number of generations>
       [--width | -w] <width of the board>
       [--height | -h] <height of the board>",
  )
}

type Args {
  Args(generations: Int, width: Int, height: Int)
}

fn parser() -> sheen.Parser(Args) {
  let assert Ok(parser) =
    sheen.new()
    |> sheen.name("Gleam of Life")
    |> sheen.version("1.0.0")
    |> sheen.authors(["alanrsoares"])
    |> sheen.build({
      use generations <-
        named.new("generations")
        |> named.short("g")
        |> named.integer()
        |> named.required()

      use width <-
        named.new("width")
        |> named.short("w")
        |> named.integer()
        |> named.optional()

      use height <-
        named.new("height")
        |> named.short("h")
        |> named.long("height")
        |> named.help("The height of the board")
        |> named.integer()
        |> named.optional()

      sheen.return({
        use generations <- generations
        use width <- width
        use height <- height

        sheen.valid(Args(
          generations,
          width
            |> option.unwrap(50),
          height
            |> option.unwrap(20),
        ))
      })
    })
  parser
}
