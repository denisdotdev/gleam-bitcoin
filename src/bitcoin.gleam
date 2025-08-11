// Re-export main types and functions for easy library usage
pub type Address {
  Address(data: BitArray, address_type: AddressType, network: Network)
}

pub type AddressType {
  P2PKH
  P2SH
  P2WPKH
  P2WSH
  P2TR
}

pub type Network {
  Mainnet
  Testnet
  Signet
  Regtest
}

pub type Transaction {
  Transaction(
    version: Int,
    inputs: List(TxIn),
    outputs: List(TxOut),
    lock_time: Int,
  )
}

pub type TxIn {
  TxIn(
    previous_output: OutPoint,
    script_sig: Script,
    sequence: Int,
    witness: List(BitArray),
  )
}

pub type TxOut {
  TxOut(value: Int, script_pubkey: Script)
}

pub type OutPoint {
  OutPoint(txid: BitArray, vout: Int)
}

pub type Script = List(ScriptElement)

pub type ScriptElement {
  Op(ScriptOpCode)
  Data(BitArray)
}

pub type ScriptOpCode {
  Op0
  Op1
  OpDup
  OpHash160
  OpEqualverify
  OpChecksig
  OpEqual
  OpCheckmultisig
  OpReturn
}

pub type KeyPair {
  KeyPair(private_key: BitArray, public_key: BitArray, compressed: Bool)
}

pub type BitcoinError {
  InvalidTransaction(String)
  InvalidScript(String)
  InvalidPublicKey(String)
  InvalidAddress(String)
  SerializationError(String)
  EncodingError(String)
}

// Import the actual implementations
import address
import encoding/base58
import encoding/hexadecimal
import encoding/utility
import transaction
import gleam/result

// Address functions
pub fn create_p2pkh_address(pubkey: BitArray, network: Network) -> Result(Address, BitcoinError) {
  address.create_p2pkh_address(pubkey, network)
  |> result.map_error(fn(_) { InvalidAddress("Failed to create P2PKH address") })
}

pub fn create_p2sh_address(script_hash: BitArray, network: Network) -> Result(Address, BitcoinError) {
  address.create_p2sh_address(script_hash, network)
  |> result.map_error(fn(_) { InvalidAddress("Failed to create P2SH address") })
}

pub fn create_p2wpkh_address(pubkey: BitArray, network: Network) -> Result(Address, BitcoinError) {
  address.create_p2wpkh_address(pubkey, network)
  |> result.map_error(fn(_) { InvalidAddress("Failed to create P2WPKH address") })
}

pub fn address_to_string(address: Address) -> Result(String, BitcoinError) {
  address.address_to_string(address)
  |> result.map_error(fn(_) { InvalidAddress("Failed to encode address") })
}

pub fn string_to_address(addr_str: String, network: Network) -> Result(Address, BitcoinError) {
  address.string_to_address(addr_str, network)
  |> result.map_error(fn(_) { InvalidAddress("Invalid address string") })
}

pub fn validate_address(addr_str: String, network: Network) -> Bool {
  address.validate_address(addr_str, network)
}

// Transaction functions
pub fn new_transaction() -> Transaction {
  transaction.new_transaction()
}

pub fn add_input(
  tx: Transaction,
  txid: BitArray,
  vout: Int,
  script_sig: Script,
  sequence: Int,
) -> Transaction {
  transaction.add_input(tx, txid, vout, script_sig, sequence)
}

pub fn add_output(
  tx: Transaction,
  value: Int,
  script_pubkey: Script,
) -> Transaction {
  transaction.add_output(tx, value, script_pubkey)
}

pub fn serialize_transaction(tx: Transaction) -> Result(BitArray, BitcoinError) {
  transaction.serialize_transaction(tx)
  |> result.map_error(fn(_) { SerializationError("Failed to serialize transaction") })
}

pub fn transaction_id(tx: Transaction) -> Result(BitArray, BitcoinError) {
  transaction.transaction_id(tx)
  |> result.map_error(fn(_) { SerializationError("Failed to compute transaction ID") })
}

pub fn transaction_hash(tx: Transaction) -> Result(String, BitcoinError) {
  transaction.transaction_hash(tx)
  |> result.map_error(fn(_) { SerializationError("Failed to compute transaction hash") })
}

// Encoding functions
pub fn hex_encode(data: BitArray) -> String {
  hexadecimal.hex_encode(data)
}

pub fn hex_decode(hex: String) -> Result(BitArray, BitcoinError) {
  hexadecimal.hex_decode(hex)
  |> result.map_error(fn(_) { EncodingError("Invalid hex string") })
}

pub fn base58_encode(data: BitArray) -> Result(String, BitcoinError) {
  base58.base58_encode(data)
  |> result.map_error(fn(_) { EncodingError("Base58 encoding failed") })
}

pub fn base58_decode(encoded: String) -> Result(BitArray, BitcoinError) {
  base58.base58_decode(encoded)
  |> result.map_error(fn(_) { EncodingError("Invalid Base58 string") })
}

// Utility functions
pub fn sha256(data: BitArray) -> BitArray {
  utility.sha256(data)
}

pub fn hash160(data: BitArray) -> BitArray {
  utility.hash160(data)
}

pub fn double_sha256(data: BitArray) -> BitArray {
  utility.double_sha256(data)
}

// Script building helpers
pub fn p2pkh_script(pubkey_hash: BitArray) -> Script {
  [
    Op(OpDup),
    Op(OpHash160),
    Data(pubkey_hash),
    Op(OpEqualverify),
    Op(OpChecksig),
  ]
}

pub fn p2sh_script(script_hash: BitArray) -> Script {
  [
    Op(OpHash160),
    Data(script_hash),
    Op(OpEqual),
  ]
}

pub fn p2wpkh_script(pubkey_hash: BitArray) -> Script {
  [
    Op(Op0),
    Data(pubkey_hash),
  ]
}

// Constants
pub const satoshis_per_bitcoin = 100_000_000
pub const max_block_size = 1_000_000
pub const max_block_weight = 4_000_000
