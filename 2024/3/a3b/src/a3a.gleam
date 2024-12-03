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
  let assert Ok(re) = regexp.from_string("(do[(][)])|(don't[(][)])|mul[(]([0-9]+),([0-9]+)[)]")

  {regexp.scan(re, program)
    |> list.fold(#(0, True), fn(s, m) {
      case m.submatches, s.1 {
        [Some(_)], _ -> #(s.0, True)
        [_, Some(_)], _ -> #(s.0, False)
        [_, _, Some(x), Some(y)], True -> {
          let assert Ok(x) = int.base_parse(x, 10)
          let assert Ok(y) = int.base_parse(y, 10)
          #(s.0 + x * y, s.1)
        }
        _, _ -> s
      }
    }) }.0
    |> io.debug
}
