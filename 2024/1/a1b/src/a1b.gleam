import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let assert [infile, ..] = argv.load().arguments
  let assert Ok(input) = simplifile.read(infile)

  let #(left, right) = input
    |> string.split("\n")
    |> list.filter(fn(l) { l != "" })
    |> list.fold(#([], []), fn(lists, l) {
      let assert [left, right] = string.split(l, "   ")
      let assert Ok(left) = int.base_parse(left, 10)
      let assert Ok(right) = int.base_parse(right, 10)

      #([left, ..lists.0], [right, ..lists.1])
    })

  let res = left
    |> list.map(fn(x) {
      {
        right
          |> list.filter(fn(y) { y == x })
          |> list.length
      } * x
    })
    |> list.fold(0, fn(x, y) { x + y })

  io.debug(res)
}
