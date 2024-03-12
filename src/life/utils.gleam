import gleam/list
import gleam/string

pub fn join_list(chars: List(String)) -> String {
  chars
  |> list.fold("", string.append)
}
