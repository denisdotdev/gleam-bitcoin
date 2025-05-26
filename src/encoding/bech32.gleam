import gleam/bit_array
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
