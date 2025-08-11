import encoding/base58
import encoding/bech32
import encoding/utility
import types/address.{type Address, type AddressType, Address, P2PKH, P2SH, P2WPKH, P2WSH, P2TR}
import types/keypair.{type PublicKey}
import types/network.{type Network, Mainnet, Testnet, Signet, Regtest}
import gleam/bit_array
import gleam/list
import gleam/result
import gleam/string

pub type AddressError {
  InvalidAddress(String)
  InvalidNetwork
  UnsupportedAddressType
}

pub fn create_p2pkh_address(pubkey: PublicKey, network: Network) -> Result(Address, AddressError) {
  let pubkey_hash = utility.hash160(pubkey)
  Ok(Address(pubkey_hash, P2PKH, network))
}

pub fn create_p2sh_address(script_hash: BitArray, network: Network) -> Result(Address, AddressError) {
  Ok(Address(script_hash, P2SH, network))
}

pub fn create_p2wpkh_address(pubkey: PublicKey, network: Network) -> Result(Address, AddressError) {
  let pubkey_hash = utility.hash160(pubkey)
  Ok(Address(pubkey_hash, P2WPKH, network))
}

pub fn create_p2wsh_address(script_hash: BitArray, network: Network) -> Result(Address, AddressError) {
  Ok(Address(script_hash, P2WSH, network))
}

pub fn create_p2tr_address(tweaked_pubkey: BitArray, network: Network) -> Result(Address, AddressError) {
  Ok(Address(tweaked_pubkey, P2TR, network))
}

pub fn address_to_string(address: Address) -> Result(String, AddressError) {
  let Address(data, addr_type, network) = address
  
  case addr_type {
    P2PKH -> legacy_address_to_string(data, get_p2pkh_version(network))
    P2SH -> legacy_address_to_string(data, get_p2sh_version(network))
    P2WPKH -> segwit_address_to_string(data, get_bech32_hrp(network), bech32.Bech32)
    P2WSH -> segwit_address_to_string(data, get_bech32_hrp(network), bech32.Bech32)
    P2TR -> segwit_address_to_string(data, get_bech32_hrp(network), bech32.Bech32m)
  }
}

pub fn string_to_address(addr_str: String, network: Network) -> Result(Address, AddressError) {
  case detect_address_type(addr_str, network) {
    Ok(#(data, addr_type)) -> Ok(Address(data, addr_type, network))
    Error(e) -> Error(e)
  }
}

pub fn validate_address(addr_str: String, network: Network) -> Bool {
  case string_to_address(addr_str, network) {
    Ok(_) -> True
    Error(_) -> False
  }
}

fn legacy_address_to_string(hash: BitArray, version: Int) -> Result(String, AddressError) {
  let version_byte = <<version>>
  let payload = bit_array.concat([version_byte, hash])
  let checksum = utility.checksum(payload)
  let full_payload = bit_array.concat([payload, checksum])
  
  case base58.base58_encode(full_payload) {
    Ok(encoded) -> Ok(encoded)
    Error(_) -> Error(InvalidAddress("Failed to encode address"))
  }
}

fn segwit_address_to_string(data: BitArray, hrp: String, variant: bech32.Bech32Variant) -> Result(String, AddressError) {
  let witness_version = case bit_array.byte_size(data) {
    20 -> 0  // P2WPKH
    32 -> 0  // P2WSH  
    _ -> 1   // P2TR
  }
  
  let data_list = convert_bitarray_to_bytes(data)
  case utility.convert_bits(data_list, 8, 5, True) {
    Ok(converted) -> {
      let witness_data = [witness_version, ..converted]
      case bech32.bech32_encode(hrp, witness_data, variant) {
        Ok(encoded) -> Ok(encoded)
        Error(_) -> Error(InvalidAddress("Failed to encode segwit address"))
      }
    }
    Error(_) -> Error(InvalidAddress("Failed to convert bits"))
  }
}

fn detect_address_type(addr_str: String, network: Network) -> Result(#(BitArray, AddressType), AddressError) {
  let hrp = get_bech32_hrp(network)
  case string.starts_with(addr_str, hrp <> "1") {
    True -> decode_segwit_address(addr_str, network)
    False -> decode_legacy_address(addr_str, network)
  }
}

fn decode_legacy_address(addr_str: String, network: Network) -> Result(#(BitArray, AddressType), AddressError) {
  case base58.base58_decode(addr_str) {
    Ok(decoded) -> {
      case bit_array.byte_size(decoded) {
        25 -> {
          case bit_array.slice(decoded, 0, 1) {
            Ok(version_byte) -> {
              let version = convert_bitarray_to_bytes(version_byte) |> list.first() |> result.unwrap(0)
              case bit_array.slice(decoded, 1, 20) {
                Ok(hash) -> {
                  case bit_array.slice(decoded, 21, 4) {
                    Ok(checksum) -> {
                      let payload = bit_array.slice(decoded, 0, 21) |> result.unwrap(<<>>)
                      let expected_checksum = utility.checksum(payload)
                      case convert_bitarray_to_bytes(checksum) == convert_bitarray_to_bytes(expected_checksum) {
                        True -> {
                          let p2pkh_version = get_p2pkh_version(network)
                          let p2sh_version = get_p2sh_version(network)
                          case version {
                            v if v == p2pkh_version -> Ok(#(hash, P2PKH))
                            v if v == p2sh_version -> Ok(#(hash, P2SH))
                            _ -> Error(InvalidAddress("Invalid version byte"))
                          }
                        }
                        False -> Error(InvalidAddress("Invalid checksum"))
                      }
                    }
                    Error(_) -> Error(InvalidAddress("Invalid address length"))
                  }
                }
                Error(_) -> Error(InvalidAddress("Invalid address length"))
              }
            }
            Error(_) -> Error(InvalidAddress("Invalid address format"))
          }
        }
        _ -> Error(InvalidAddress("Invalid address length"))
      }
    }
    Error(_) -> Error(InvalidAddress("Invalid base58 encoding"))
  }
}

fn decode_segwit_address(addr_str: String, network: Network) -> Result(#(BitArray, AddressType), AddressError) {
  case bech32.bech32_decode(addr_str) {
    Ok(#(hrp, data, variant)) -> {
      let expected_hrp = get_bech32_hrp(network)
      case hrp == expected_hrp {
        True -> {
          case data {
            [witness_version, ..witness_data] -> {
              case utility.convert_bits(witness_data, 5, 8, False) {
                Ok(converted) -> {
                  let data_bytes = convert_bytes_to_bitarray(converted)
                  case #(witness_version, bit_array.byte_size(data_bytes), variant) {
                    #(0, 20, bech32.Bech32) -> Ok(#(data_bytes, P2WPKH))
                    #(0, 32, bech32.Bech32) -> Ok(#(data_bytes, P2WSH))
                    #(1, 32, bech32.Bech32m) -> Ok(#(data_bytes, P2TR))
                    _ -> Error(InvalidAddress("Unsupported witness version or length"))
                  }
                }
                Error(_) -> Error(InvalidAddress("Failed to convert witness data"))
              }
            }
            _ -> Error(InvalidAddress("Invalid witness data"))
          }
        }
        False -> Error(InvalidAddress("Wrong network"))
      }
    }
    Error(_) -> Error(InvalidAddress("Invalid bech32 encoding"))
  }
}

fn get_p2pkh_version(network: Network) -> Int {
  case network {
    Mainnet -> 0x00
    Testnet | Signet | Regtest -> 0x6f
  }
}

fn get_p2sh_version(network: Network) -> Int {
  case network {
    Mainnet -> 0x05
    Testnet | Signet | Regtest -> 0xc4
  }
}

fn get_bech32_hrp(network: Network) -> String {
  case network {
    Mainnet -> "bc"
    Testnet -> "tb"
    Signet -> "tb"
    Regtest -> "bcrt"
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