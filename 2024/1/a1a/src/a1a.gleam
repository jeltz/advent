import argv
import file_streams/file_stream
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/yielder

fn read_lines(path) {
  let assert Ok(file) = file_stream.open_read(path)

  yielder.unfold(file, fn(f) {
    case file_stream.read_line(f) {
      Ok(line) -> yielder.Next(line, f)
      _ -> yielder.Done
    }
  })
}

pub fn main() {
  let assert [infile, ..] = argv.load().arguments

  let #(left, right) = read_lines(infile)
    |> yielder.fold(#([], []), fn(lists, line) {
      let l = string.trim_end(line)
      let assert [left, right] = string.split(l, "   ")
      let assert Ok(left) = int.base_parse(left, 10)
      let assert Ok(right) = int.base_parse(right, 10)

      #([left, ..lists.0], [right, ..lists.1])
    })

  let left = list.sort(left, int.compare)
  let right = list.sort(right, int.compare)

  let res = list.zip(left, right)
    |> list.map(fn(t) { int.absolute_value(t.0 - t.1) })
    |> list.fold(0, fn(x, y) { x + y })

  io.debug(res)
}
