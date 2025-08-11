# Gleam Bitcoin

[![Package Version](https://img.shields.io/hexpm/v/bitcoin)](https://hex.pm/packages/bitcoin)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/bitcoin/)

A comprehensive Bitcoin library for Gleam that provides functionality for working with Bitcoin addresses, transactions, and cryptographic operations.

## Features

- **Address Generation & Validation**: Support for all major Bitcoin address types
  - P2PKH (Pay-to-Public-Key-Hash)
  - P2SH (Pay-to-Script-Hash) 
  - P2WPKH (Pay-to-Witness-Public-Key-Hash)
  - P2WSH (Pay-to-Witness-Script-Hash)
  - P2TR (Pay-to-Taproot)

- **Transaction Building**: Create and serialize Bitcoin transactions
  - Legacy and SegWit transaction support
  - Input/output management
  - Transaction ID calculation
  - Witness data handling

- **Encoding Utilities**: Bitcoin-specific encoding functions
  - Base58 encoding/decoding
  - Bech32 encoding/decoding  
  - Hexadecimal utilities
  - Hash functions (SHA256, Hash160, Double SHA256)

- **Multi-Network Support**: Works with all Bitcoin networks
  - Mainnet
  - Testnet
  - Signet
  - Regtest

## Installation

Add `bitcoin` to your Gleam project:

```sh
gleam add bitcoin@1
```

## Quick Start

```gleam
import bitcoin
import bitcoin.{type Address, type Network, Mainnet}
import gleam/io

pub fn main() -> Nil {
  // Create a P2PKH address from a public key
  let pubkey = <<0x02, 0x79, 0xbe, 0x66, 0x7e, 0xf9, 0xdc, 0xbb, 0xac, 0x55, 0xa0, 0x62, 0x95, 0xce, 0x87, 0x0b, 0x07, 0x02, 0x9b, 0xfC, 0xdb, 0x2d, 0xce, 0x28, 0xd9, 0x59, 0xf2, 0x81, 0x5b, 0x16, 0xf8, 0x17, 0x98>>
  
  case bitcoin.create_p2pkh_address(pubkey, Mainnet) {
    Ok(address) -> {
      case bitcoin.address_to_string(address) {
        Ok(addr_string) -> {
          io.println("Generated address: " <> addr_string)
        }
        Error(_) -> io.println("Failed to encode address")
      }
    }
    Error(_) -> io.println("Failed to create address")
  }
}
```

## API Reference

### Address Functions

#### `create_p2pkh_address(pubkey: BitArray, network: Network) -> Result(Address, BitcoinError)`
Create a Pay-to-Public-Key-Hash address from a public key.

#### `create_p2sh_address(script_hash: BitArray, network: Network) -> Result(Address, BitcoinError)`
Create a Pay-to-Script-Hash address from a script hash.

#### `create_p2wpkh_address(pubkey: BitArray, network: Network) -> Result(Address, BitcoinError)`  
Create a Pay-to-Witness-Public-Key-Hash (SegWit v0) address.

#### `address_to_string(address: Address) -> Result(String, BitcoinError)`
Convert an Address to its string representation.

#### `string_to_address(addr_str: String, network: Network) -> Result(Address, BitcoinError)`
Parse an address string into an Address type.

#### `validate_address(addr_str: String, network: Network) -> Bool`
Validate an address string for a specific network.

### Transaction Functions

#### `new_transaction() -> Transaction`
Create a new empty transaction.

#### `add_input(tx: Transaction, txid: BitArray, vout: Int, script_sig: Script, sequence: Int) -> Transaction`
Add an input to a transaction.

#### `add_output(tx: Transaction, value: Int, script_pubkey: Script) -> Transaction`
Add an output to a transaction.

#### `serialize_transaction(tx: Transaction) -> Result(BitArray, BitcoinError)`
Serialize a transaction to bytes.

#### `transaction_id(tx: Transaction) -> Result(BitArray, BitcoinError)`
Calculate the transaction ID (double SHA256 of serialized transaction).

#### `transaction_hash(tx: Transaction) -> Result(String, BitcoinError)`
Get the transaction hash as a hex string.

### Encoding Functions

#### `hex_encode(data: BitArray) -> String`
Encode binary data to hexadecimal string.

#### `hex_decode(hex: String) -> Result(BitArray, BitcoinError)`
Decode hexadecimal string to binary data.

#### `base58_encode(data: BitArray) -> Result(String, BitcoinError)`
Encode binary data using Base58 encoding.

#### `base58_decode(encoded: String) -> Result(BitArray, BitcoinError)`
Decode Base58 string to binary data.

### Cryptographic Functions

#### `sha256(data: BitArray) -> BitArray`
Calculate SHA256 hash of input data.

#### `hash160(data: BitArray) -> BitArray`
Calculate Hash160 (RIPEMD160(SHA256(data))) of input data.

#### `double_sha256(data: BitArray) -> BitArray`
Calculate double SHA256 hash (SHA256(SHA256(data))) of input data.

### Script Helpers

#### `p2pkh_script(pubkey_hash: BitArray) -> Script`
Create a Pay-to-Public-Key-Hash script.

#### `p2sh_script(script_hash: BitArray) -> Script`  
Create a Pay-to-Script-Hash script.

#### `p2wpkh_script(pubkey_hash: BitArray) -> Script`
Create a Pay-to-Witness-Public-Key-Hash script.

## Examples

### Creating Different Address Types

```gleam
import bitcoin
import bitcoin.{Mainnet, Testnet}

// P2PKH Address
let pubkey = <</* 33-byte public key */>>
let p2pkh_result = bitcoin.create_p2pkh_address(pubkey, Mainnet)

// P2SH Address  
let script_hash = <</* 20-byte script hash */>>
let p2sh_result = bitcoin.create_p2sh_address(script_hash, Mainnet)

// P2WPKH Address (SegWit v0)
let p2wpkh_result = bitcoin.create_p2wpkh_address(pubkey, Mainnet)
```

### Building a Transaction

```gleam
import bitcoin
import gleam/result

pub fn build_simple_transaction() {
  // Create new transaction
  let tx = bitcoin.new_transaction()
  
  // Add input
  let prev_txid = bitcoin.hex_decode("a1b2c3d4...") |> result.unwrap(<<>>)
  let script_sig = []
  let tx = bitcoin.add_input(tx, prev_txid, 0, script_sig, 0xffffffff)
  
  // Add output
  let recipient_hash = <</* 20-byte hash */>>
  let output_script = bitcoin.p2pkh_script(recipient_hash)
  let tx = bitcoin.add_output(tx, 50_000_000, output_script) // 0.5 BTC
  
  // Serialize transaction
  case bitcoin.serialize_transaction(tx) {
    Ok(serialized) -> {
      let hex_tx = bitcoin.hex_encode(serialized)
      io.println("Transaction hex: " <> hex_tx)
    }
    Error(e) -> io.println("Serialization failed")
  }
}
```

### Address Validation

```gleam
import bitcoin
import bitcoin.{Mainnet}
import gleam/io

pub fn validate_user_address(addr_str: String) {
  case bitcoin.validate_address(addr_str, Mainnet) {
    True -> io.println("Valid address")
    False -> io.println("Invalid address")
  }
}
```

### Working with Different Networks

```gleam
import bitcoin
import bitcoin.{Mainnet, Testnet, Signet, Regtest}

// Mainnet address
let mainnet_addr = bitcoin.create_p2pkh_address(pubkey, Mainnet)

// Testnet address  
let testnet_addr = bitcoin.create_p2pkh_address(pubkey, Testnet)

// Each network has different address formats
```

## Error Handling

The library uses Gleam's Result type for error handling. All functions that can fail return `Result(T, BitcoinError)` where `BitcoinError` variants include:

- `InvalidTransaction(String)` - Transaction validation errors
- `InvalidScript(String)` - Script parsing/validation errors  
- `InvalidPublicKey(String)` - Public key format errors
- `InvalidAddress(String)` - Address format/validation errors
- `SerializationError(String)` - Binary serialization errors
- `EncodingError(String)` - Encoding/decoding errors

## Constants

The library provides useful Bitcoin constants:

```gleam
bitcoin.satoshis_per_bitcoin // 100,000,000
bitcoin.max_block_size      // 1,000,000 
bitcoin.max_block_weight    // 4,000,000
```

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam build # Build the project
```

Further documentation can be found at <https://hexdocs.pm/bitcoin>.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This library implements Bitcoin functionality according to the Bitcoin protocol specifications and follows established patterns from other Bitcoin libraries.
