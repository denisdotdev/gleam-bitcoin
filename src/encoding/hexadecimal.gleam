import gleam/bit_array
import gleam/list
import gleam/result
import gleam/string

pub type HexError {
  InvalidHexCharacter(String)
  InvalidLength
  EmptyInput
}

pub fn hex_encode(data: BitArray) -> String {
  convert_bitarray_to_bytes(data)
  |> list.map(byte_to_hex)
  |> string.join("")
}

pub fn hex_decode(hex: String) -> Result(BitArray, HexError) {
  case string.length(hex) {
    0 -> Error(EmptyInput)
    len if len % 2 != 0 -> Error(InvalidLength)
    _ -> {
      hex
      |> string.lowercase()
      |> string.to_graphemes()
      |> list.sized_chunk(2)
      |> list.try_map(hex_pair_to_byte)
      |> result.map(convert_bytes_to_bitarray)
      |> result.map_error(fn(_) { InvalidLength })
    }
  }
}

pub fn hex_encode_reverse(data: BitArray) -> String {
  data
  |> convert_bitarray_to_bytes()
  |> list.reverse()
  |> convert_bytes_to_bitarray()
  |> hex_encode()
}

pub fn hex_decode_reverse(hex: String) -> Result(BitArray, HexError) {
  case hex_decode(hex) {
    Ok(data) -> {
      data
      |> convert_bitarray_to_bytes()
      |> list.reverse()
      |> convert_bytes_to_bitarray()
      |> Ok
    }
    Error(e) -> Error(e)
  }
}

fn byte_to_hex(byte: Int) -> String {
  let high = byte / 16
  let low = byte % 16
  nibble_to_hex(high) <> nibble_to_hex(low)
}

fn nibble_to_hex(nibble: Int) -> String {
  case nibble {
    0 -> "0"
    1 -> "1"
    2 -> "2"
    3 -> "3"
    4 -> "4"
    5 -> "5"
    6 -> "6"
    7 -> "7"
    8 -> "8"
    9 -> "9"
    10 -> "a"
    11 -> "b"
    12 -> "c"
    13 -> "d"
    14 -> "e"
    15 -> "f"
    _ -> "0"
  }
}

fn hex_pair_to_byte(pair: List(String)) -> Result(Int, HexError) {
  case pair {
    [high, low] -> {
      use high_val <- result.try(hex_char_to_nibble(high))
      use low_val <- result.try(hex_char_to_nibble(low))
      Ok(high_val * 16 + low_val)
    }
    _ -> Error(InvalidLength)
  }
}

fn hex_char_to_nibble(char: String) -> Result(Int, HexError) {
  case char {
    "0" -> Ok(0)
    "1" -> Ok(1)
    "2" -> Ok(2)
    "3" -> Ok(3)
    "4" -> Ok(4)
    "5" -> Ok(5)
    "6" -> Ok(6)
    "7" -> Ok(7)
    "8" -> Ok(8)
    "9" -> Ok(9)
    "a" -> Ok(10)
    "b" -> Ok(11)
    "c" -> Ok(12)
    "d" -> Ok(13)
    "e" -> Ok(14)
    "f" -> Ok(15)
    _ -> Error(InvalidHexCharacter(char))
  }
}

fn convert_bitarray_to_bytes(data: BitArray) -> List(Int) {
  convert_bitarray_to_bytes_helper(data, [])
}

fn convert_bitarray_to_bytes_helper(data: BitArray, acc: List(Int)) -> List(Int) {
  case bit_array.slice(data, 0, 1) {
    Ok(<<byte:8>>) -> {
      let rest = bit_array.slice(data, 1, bit_array.byte_size(data) - 1) |> result.unwrap(<<>>)
      convert_bitarray_to_bytes_helper(rest, [byte, ..acc])
    }
    _ -> list.reverse(acc)
  }
}

fn convert_bytes_to_bitarray(bytes: List(Int)) -> BitArray {
  list.fold(bytes, <<>>, fn(acc, byte) {
    bit_array.concat([acc, <<byte:8>>])
  })
}