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

  let valid = read_lines(infile)
    |> yielder.map(fn(line) {
      let l = string.trim_end(line)
      let levels = string.split(l, " ")
        |> list.map(fn(l) {
          let assert Ok(x) = int.base_parse(l, 10)
          x
        })

      {
        levels
          |> list.window_by_2()
          |> list.all(fn(p) { p.0 > p.1 && p.0 - p.1 <= 3 })
      } || {
        levels
          |> list.window_by_2()
          |> list.all(fn(p) { p.0 < p.1  && p.1 - p.0 <= 3 })
      }
    })
    |> yielder.filter(fn(b) { b })
    |> yielder.length()

  io.debug(valid)
}
