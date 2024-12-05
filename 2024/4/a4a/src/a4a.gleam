import argv
import file_streams/file_stream
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

fn find(board, x, y, dx, dy) {
  dict.get(board, #(x + dx * 0, y + dy * 0)) == Ok("X") &&
  dict.get(board, #(x + dx * 1, y + dy * 1)) == Ok("M") &&
  dict.get(board, #(x + dx * 2, y + dy * 2)) == Ok("A") &&
  dict.get(board, #(x + dx * 3, y + dy * 3)) == Ok("S")
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
            [
              find(board, i, j, -1, -1),
              find(board, i, j, -1,  0),
              find(board, i, j, -1,  1),
              find(board, i, j,  0, -1),
              find(board, i, j,  0,  1),
              find(board, i, j,  1, -1),
              find(board, i, j,  1,  0),
              find(board, i, j,  1,  1),
            ] |>
              list.count(fn(b) { b })
          })
          |> yielder.fold(0, int.add)
    })
    |> yielder.fold(0, int.add)
    |> io.debug
}
