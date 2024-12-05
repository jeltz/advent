import argv
import file_streams/file_stream
import gleam/bool
import gleam/int
import gleam/io
import gleam/dict
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

fn find(board, x, y) {
  dict.get(board, #(x, y)) == Ok("A") &&
  {
    dict.get(board, #(x - 1, y - 1)) == Ok("M") &&
    dict.get(board, #(x + 1, y + 1)) == Ok("S") ||
    dict.get(board, #(x - 1, y - 1)) == Ok("S") &&
    dict.get(board, #(x + 1, y + 1)) == Ok("M")
  } &&
  {
    dict.get(board, #(x - 1, y + 1)) == Ok("M") &&
    dict.get(board, #(x + 1, y - 1)) == Ok("S") ||
    dict.get(board, #(x - 1, y + 1)) == Ok("S") &&
    dict.get(board, #(x + 1, y - 1)) == Ok("M")
  }
}

pub fn main() {
  let assert [infile, ..] = argv.load().arguments

  let board = read_lines(infile)
    |> yielder.zip(yielder.unfold(0, fn(i) { yielder.Next(i, i + 1) }))
    |> yielder.fold(dict.new(), fn(d, arg) {
      let line = string.trim_end(arg.0)
      let i = arg.1

      string.to_graphemes(line)
        |> list.index_fold(d, fn(d, c, j) {
          dict.insert(d, #(i, j), c)
        })
    })

  yielder.unfold(0, fn(i) { yielder.Next(i, i + 1) })
    |> yielder.take_while(fn(i) { dict.has_key(board, #(i, 0)) })
    |> yielder.map(fn(i) {
        yielder.unfold(0, fn(i) { yielder.Next(i, i + 1) })
          |> yielder.take_while(fn(j) { dict.has_key(board, #(i, j)) })
          |> yielder.map(fn(j) {
            bool.to_int(find(board, i, j))
          })
          |> yielder.fold(0, int.add)
    })
    |> yielder.fold(0, int.add)
    |> io.debug
}
