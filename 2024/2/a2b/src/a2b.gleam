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

fn valid_inc(levels, skip) {
  case levels, skip {
    [], _ -> True
    [_], _ -> True
    [x, y, ..levels], _ if x < y && y - x <= 3 -> valid_inc([y, ..levels], skip)
    [x, y, ..levels], False -> valid_inc([x, ..levels], True) || valid_inc([y, ..levels], True)
    _, True -> False
  }
}

fn valid_dec(levels, skip) {
  case levels, skip {
    [], _ -> True
    [_], _ -> True
    [x, y, ..levels], _ if x > y && x - y <= 3 -> valid_dec([y, ..levels], skip)
    [x, y, ..levels], False -> valid_inc([x, ..levels], True) || valid_inc([y, ..levels], True)
    _, True -> False
  }
}

pub fn main() {
  let assert [infile, ..] = argv.load().arguments

  read_lines(infile)
    |> yielder.map(fn(line) {
      let l = string.trim_end(line)
      let levels = string.split(l, " ")
        |> list.map(fn(l) {
          let assert Ok(x) = int.base_parse(l, 10)
          x
        })

      valid_inc(levels, False) || valid_dec(levels, False)
    })
    |> yielder.filter(fn(b) { b })
    |> yielder.length
    |> io.debug
}
