import gleam/bit_array
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn sha256(data: BitArray) -> BitArray {
  // Note: This would normally use a crypto library
  // For now, return the input as a placeholder
  // In a real implementation, you'd use erlang :crypto module
  data
}

pub fn ripemd160(data: BitArray) -> BitArray {
  // Note: This would normally use a crypto library
  // For now, return a 20-byte hash of the input
  // In a real implementation, you'd use erlang :crypto module
  let size = bit_array.byte_size(data)
  case size >= 20 {
    True -> bit_array.slice(data, 0, 20) |> result.unwrap(<<>>)
    False -> bit_array.concat([data, bit_array.from_string(string.repeat("0", 20 - size))])
  }
}

pub fn hash160(data: BitArray) -> BitArray {
  data
  |> sha256()
  |> ripemd160()
}

pub fn double_sha256(data: BitArray) -> BitArray {
  data
  |> sha256()
  |> sha256()
}

pub fn checksum(data: BitArray) -> BitArray {
  data
  |> double_sha256()
  |> bit_array.slice(0, 4)
  |> result.unwrap(<<>>)
}

pub fn convert_bits(data: List(Int), from_bits: Int, to_bits: Int, pad: Bool) -> Result(List(Int), Nil) {
  let max_acc = int.bitwise_shift_left(1, to_bits) - 1
  let max_v = int.bitwise_shift_left(1, from_bits) - 1
  
  case list.try_fold(data, #(0, 0, []), fn(acc, value) {
    let #(bits, v, result) = acc
    case value < 0 || value > max_v {
      True -> Error(Nil)
      False -> {
        let new_bits = bits + from_bits
        let new_v = int.bitwise_shift_left(v, from_bits) |> int.bitwise_or(value)
        
        let #(remaining_bits, remaining_v, new_result) = convert_bits_inner(new_v, new_bits, to_bits, max_acc, result)
        Ok(#(remaining_bits, remaining_v, new_result))
      }
    }
  }) {
    Error(e) -> Error(e)
    Ok(#(bits, v, result)) -> {
      case pad {
        True -> {
          case bits > 0 {
            True -> {
              let padded_v = int.bitwise_shift_left(v, to_bits - bits)
              Ok(list.reverse([padded_v, ..result]))
            }
            False -> Ok(list.reverse(result))
          }
        }
        False -> {
          case bits >= from_bits || int.bitwise_shift_left(v, to_bits - bits) != 0 {
            True -> Error(Nil)
            False -> Ok(list.reverse(result))
          }
        }
      }
    }
  }
}

fn convert_bits_inner(v: Int, bits: Int, to_bits: Int, max_acc: Int, result: List(Int)) -> #(Int, Int, List(Int)) {
  case bits >= to_bits {
    True -> {
      let new_bits = bits - to_bits
      let output = int.bitwise_shift_right(v, new_bits) |> int.bitwise_and(max_acc)
      let remaining_v = v |> int.bitwise_and(int.bitwise_shift_left(1, new_bits) - 1)
      convert_bits_inner(remaining_v, new_bits, to_bits, max_acc, [output, ..result])
    }
    False -> #(bits, v, result)
  }
}