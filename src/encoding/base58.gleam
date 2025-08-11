import gleam/bit_array
import gleam/list
import gleam/result
import gleam/string

const base58_alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

pub type Base58Error {
  InvalidCharacter(String)
  InvalidChecksum
  EmptyInput
}

pub fn base58_encode(data: BitArray) -> Result(String, Base58Error) {
  case bit_array.byte_size(data) {
    0 -> Error(EmptyInput)
    _ -> {
      let bytes = convert_bitarray_to_bytes(data)
      let leading_zeros = count_leading_zeros(bytes, 0)
      let num = bytes_to_bigint(bytes)
      let encoded = bigint_to_base58(num, "")
      let leading_ones = string.repeat("1", leading_zeros)
      Ok(leading_ones <> encoded)
    }
  }
}

pub fn base58_decode(encoded: String) -> Result(BitArray, Base58Error) {
  case string.length(encoded) {
    0 -> Error(EmptyInput)
    _ -> {
      case validate_base58_string(encoded) {
        Error(e) -> Error(e)
        Ok(_) -> {
          let leading_ones = count_leading_ones(encoded, 0)
          let trimmed = string.drop_start(encoded, leading_ones)
          case base58_to_bigint(trimmed, 0) {
            Error(e) -> Error(e)
            Ok(num) -> {
              let bytes = bigint_to_bytes(num)
              let leading_zeros = list.repeat(0, leading_ones)
              let result_bytes = list.append(leading_zeros, bytes)
              Ok(convert_bytes_to_bitarray(result_bytes))
            }
          }
        }
      }
    }
  }
}

fn count_leading_zeros(bytes: List(Int), count: Int) -> Int {
  case bytes {
    [0, ..rest] -> count_leading_zeros(rest, count + 1)
    _ -> count
  }
}

fn count_leading_ones(s: String, count: Int) -> Int {
  case string.first(s) {
    Ok("1") -> count_leading_ones(string.drop_start(s, 1), count + 1)
    _ -> count
  }
}

fn validate_base58_string(s: String) -> Result(Nil, Base58Error) {
  string.to_graphemes(s)
  |> list.try_each(fn(char) {
    case string.contains(base58_alphabet, char) {
      True -> Ok(Nil)
      False -> Error(InvalidCharacter(char))
    }
  })
}

fn bytes_to_bigint(bytes: List(Int)) -> Int {
  list.fold(bytes, 0, fn(acc, byte) { acc * 256 + byte })
}

fn bigint_to_bytes(num: Int) -> List(Int) {
  case num {
    0 -> []
    _ -> list.append(bigint_to_bytes(num / 256), [num % 256])
  }
}

fn bigint_to_base58(num: Int, acc: String) -> String {
  case num {
    0 -> 
      case string.length(acc) {
        0 -> "1"
        _ -> acc
      }
    _ -> {
      let remainder = num % 58
      let char = string.slice(base58_alphabet, remainder, 1)
      bigint_to_base58(num / 58, char <> acc)
    }
  }
}

fn base58_to_bigint(s: String, acc: Int) -> Result(Int, Base58Error) {
  case string.first(s) {
    Error(_) -> Ok(acc)
    Ok(char) -> {
      case string.split(base58_alphabet, char) {
        [left, _] -> {
          let index = string.length(left)
          base58_to_bigint(string.drop_start(s, 1), acc * 58 + index)
        }
        _ -> Error(InvalidCharacter(char))
      }
    }
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
