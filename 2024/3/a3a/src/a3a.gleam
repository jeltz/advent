import argv
import file_streams/file_stream
import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp

pub fn main() {
  let assert [infile, ..] = argv.load().arguments
  let assert Ok(file) = file_stream.open_read(infile)
  let assert Ok(program) = file_stream.read_remaining_bytes(file)
  let assert Ok(program) = bit_array.to_string(program)
  let assert Ok(re) = regexp.from_string("mul[(]([0-9]+),([0-9]+)[)]")

  regexp.scan(re, program)
    |> list.map(fn(m) {
      m.submatches
        |> list.map(fn(x) {
          let assert Some(x) = x
          let assert Ok(x) = int.base_parse(x, 10)
          x
        })
        |> list.fold(1, fn(x, y) { x * y })
    })
    |> list.fold(0, fn(x, y) { x + y })
    |> io.debug
}
