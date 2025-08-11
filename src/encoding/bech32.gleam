import gleam/int
import gleam/list
import gleam/result
import gleam/string

const bech32_charset = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"

const bech32_const = 1

const bech32m_const = 0x2bc830a3

pub type Bech32Error {
  InvalidHrp
  InvalidData
  InvalidChecksum
  InvalidLength
  MixedCase
}

pub type Bech32Variant {
  Bech32
  Bech32m
}

pub fn bech32_encode(hrp: String, data: List(Int), variant: Bech32Variant) -> Result(String, Bech32Error) {
  case validate_hrp(hrp) {
    Error(e) -> Error(e)
    Ok(_) -> {
      let spec = case variant {
        Bech32 -> bech32_const
        Bech32m -> bech32m_const
      }
      let checksum = bech32_create_checksum(hrp, data, spec)
      let combined_data = list.append(data, checksum)
      case encode_data(combined_data) {
        Error(e) -> Error(e)
        Ok(encoded_data) -> Ok(hrp <> "1" <> encoded_data)
      }
    }
  }
}

pub fn bech32_decode(addr: String) -> Result(#(String, List(Int), Bech32Variant), Bech32Error) {
  case string.split(addr, "1") {
    [hrp, data_part] -> {
      case validate_hrp(hrp) {
        Error(e) -> Error(e)
        Ok(_) -> {
          case decode_data(data_part) {
            Error(e) -> Error(e)
            Ok(decoded) -> {
              case list.split(decoded, list.length(decoded) - 6) {
                #(data, _checksum) -> {
                  case bech32_verify_checksum(hrp, decoded, bech32_const) {
                    True -> Ok(#(hrp, data, Bech32))
                    False -> {
                      case bech32_verify_checksum(hrp, decoded, bech32m_const) {
                        True -> Ok(#(hrp, data, Bech32m))
                        False -> Error(InvalidChecksum)
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    _ -> Error(InvalidData)
  }
}

fn validate_hrp(hrp: String) -> Result(Nil, Bech32Error) {
  case string.length(hrp) {
    0 -> Error(InvalidHrp)
    len if len > 83 -> Error(InvalidHrp)
    _ -> {
      hrp
      |> string.to_utf_codepoints()
      |> list.try_each(fn(cp) {
        let code = string.utf_codepoint_to_int(cp)
        case code >= 33 && code <= 126 {
          True -> Ok(Nil)
          False -> Error(InvalidHrp)
        }
      })
    }
  }
}

fn encode_data(data: List(Int)) -> Result(String, Bech32Error) {
  data
  |> list.try_map(fn(val) {
    case val >= 0 && val < 32 {
      True -> Ok(string.slice(bech32_charset, val, 1))
      False -> Error(InvalidData)
    }
  })
  |> result.map(string.join(_, ""))
}

fn decode_data(data: String) -> Result(List(Int), Bech32Error) {
  data
  |> string.to_graphemes()
  |> list.try_map(fn(char) {
    case string.split(bech32_charset, char) {
      [left, _] -> Ok(string.length(left))
      _ -> Error(InvalidData)
    }
  })
}

fn bech32_create_checksum(hrp: String, data: List(Int), spec: Int) -> List(Int) {
  let values = list.append(bech32_hrp_expand(hrp), list.append(data, [0, 0, 0, 0, 0, 0]))
  let polymod = bech32_polymod(values) |> int.bitwise_exclusive_or(spec)
  [
    int.bitwise_shift_right(polymod, 25) |> int.bitwise_and(31),
    int.bitwise_shift_right(polymod, 20) |> int.bitwise_and(31),
    int.bitwise_shift_right(polymod, 15) |> int.bitwise_and(31),
    int.bitwise_shift_right(polymod, 10) |> int.bitwise_and(31),
    int.bitwise_shift_right(polymod, 5) |> int.bitwise_and(31),
    polymod |> int.bitwise_and(31),
  ]
}

fn bech32_verify_checksum(hrp: String, data: List(Int), spec: Int) -> Bool {
  let values = list.append(bech32_hrp_expand(hrp), data)
  bech32_polymod(values) == spec
}

fn bech32_hrp_expand(hrp: String) -> List(Int) {
  let chars = string.to_utf_codepoints(hrp)
  let high = list.map(chars, fn(cp) { int.bitwise_shift_right(string.utf_codepoint_to_int(cp), 5) })
  let low = list.map(chars, fn(cp) { int.bitwise_and(string.utf_codepoint_to_int(cp), 31) })
  list.append(list.append(high, [0]), low)
}

fn bech32_polymod(values: List(Int)) -> Int {
  let generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
  
  list.fold(values, 1, fn(chk, value) {
    let top = int.bitwise_shift_right(chk, 25)
    let new_chk = int.bitwise_shift_left(int.bitwise_and(chk, 0x1ffffff), 5) |> int.bitwise_exclusive_or(value)
    
    list.index_fold(generator, new_chk, fn(acc, gen, i) {
      case int.bitwise_and(int.bitwise_shift_right(top, i), 1) == 1 {
        True -> int.bitwise_exclusive_or(acc, gen)
        False -> acc
      }
    })
  })
}
