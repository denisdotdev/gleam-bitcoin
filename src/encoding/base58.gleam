import bitcoin/types/errors.{type BitcoinError, EncodingError}
import gleam/bit_array
import gleam/bool
import gleam/int
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
  todo
}

pub fn base58_decode(encoded: String) -> Result(BitArray, Base58Error) {
  todo
}
