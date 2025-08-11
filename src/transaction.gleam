import encoding/hexadecimal
import encoding/utility
import types/script.{type Script}
import types/transaction.{type Transaction, type TxIn, type TxOut, type OutPoint, Transaction, TxIn, TxOut, OutPoint}
import gleam/bit_array
import gleam/list
import gleam/result

pub type SerializationError {
  InvalidInput
  SerializationFailed
}

pub fn new_transaction() -> Transaction {
  Transaction(version: 1, inputs: [], outputs: [], lock_time: 0)
}

pub fn add_input(
  tx: Transaction,
  txid: BitArray,
  vout: Int,
  script_sig: Script,
  sequence: Int,
) -> Transaction {
  let Transaction(version, inputs, outputs, lock_time) = tx
  let outpoint = OutPoint(txid, vout)
  let input = TxIn(outpoint, script_sig, sequence, [])
  Transaction(version, [input, ..inputs], outputs, lock_time)
}

pub fn add_witness_input(
  tx: Transaction,
  txid: BitArray,
  vout: Int,
  script_sig: Script,
  sequence: Int,
  witness: List(BitArray),
) -> Transaction {
  let Transaction(version, inputs, outputs, lock_time) = tx
  let outpoint = OutPoint(txid, vout)
  let input = TxIn(outpoint, script_sig, sequence, witness)
  Transaction(version, [input, ..inputs], outputs, lock_time)
}

pub fn add_output(
  tx: Transaction,
  value: Int,
  script_pubkey: Script,
) -> Transaction {
  let Transaction(version, inputs, outputs, lock_time) = tx
  let output = TxOut(value, script_pubkey)
  Transaction(version, inputs, [output, ..outputs], lock_time)
}

pub fn set_lock_time(tx: Transaction, lock_time: Int) -> Transaction {
  let Transaction(version, inputs, outputs, _) = tx
  Transaction(version, inputs, outputs, lock_time)
}

pub fn set_version(tx: Transaction, version: Int) -> Transaction {
  let Transaction(_, inputs, outputs, lock_time) = tx
  Transaction(version, inputs, outputs, lock_time)
}

pub fn serialize_transaction(tx: Transaction) -> Result(BitArray, SerializationError) {
  let Transaction(version, inputs, outputs, lock_time) = tx
  
  use version_bytes <- result.try(serialize_u32_le(version))
  use input_count <- result.try(serialize_varint(list.length(inputs)))
  use serialized_inputs <- result.try(serialize_inputs(inputs))
  use output_count <- result.try(serialize_varint(list.length(outputs)))
  use serialized_outputs <- result.try(serialize_outputs(outputs))
  use lock_time_bytes <- result.try(serialize_u32_le(lock_time))
  
  Ok(bit_array.concat([
    version_bytes,
    input_count,
    serialized_inputs,
    output_count,
    serialized_outputs,
    lock_time_bytes,
  ]))
}

pub fn transaction_id(tx: Transaction) -> Result(BitArray, SerializationError) {
  use serialized <- result.try(serialize_transaction(tx))
  Ok(utility.double_sha256(serialized))
}

pub fn transaction_hash(tx: Transaction) -> Result(String, SerializationError) {
  use txid <- result.try(transaction_id(tx))
  Ok(hexadecimal.hex_encode_reverse(txid))
}

pub fn serialize_witness_transaction(tx: Transaction) -> Result(BitArray, SerializationError) {
  let Transaction(version, inputs, outputs, lock_time) = tx
  
  let has_witness = list.any(inputs, fn(input) { list.length(input.witness) > 0 })
  
  case has_witness {
    False -> serialize_transaction(tx)
    True -> {
      use version_bytes <- result.try(serialize_u32_le(version))
      let marker = <<0>>
      let flag = <<1>>
      use input_count <- result.try(serialize_varint(list.length(inputs)))
      use serialized_inputs <- result.try(serialize_inputs(inputs))
      use output_count <- result.try(serialize_varint(list.length(outputs)))
      use serialized_outputs <- result.try(serialize_outputs(outputs))
      use witness_data <- result.try(serialize_witness_data(inputs))
      use lock_time_bytes <- result.try(serialize_u32_le(lock_time))
      
      Ok(bit_array.concat([
        version_bytes,
        marker,
        flag,
        input_count,
        serialized_inputs,
        output_count,
        serialized_outputs,
        witness_data,
        lock_time_bytes,
      ]))
    }
  }
}

fn serialize_inputs(inputs: List(TxIn)) -> Result(BitArray, SerializationError) {
  inputs
  |> list.try_map(serialize_input)
  |> result.map(bit_array.concat)
}

fn serialize_input(input: TxIn) -> Result(BitArray, SerializationError) {
  let TxIn(prev_output, script_sig, sequence, _witness) = input
  
  use outpoint_bytes <- result.try(serialize_outpoint(prev_output))
  use script_bytes <- result.try(serialize_script(script_sig))
  use sequence_bytes <- result.try(serialize_u32_le(sequence))
  
  Ok(bit_array.concat([outpoint_bytes, script_bytes, sequence_bytes]))
}

fn serialize_outpoint(outpoint: OutPoint) -> Result(BitArray, SerializationError) {
  let OutPoint(txid, vout) = outpoint
  use vout_bytes <- result.try(serialize_u32_le(vout))
  Ok(bit_array.concat([txid, vout_bytes]))
}

fn serialize_outputs(outputs: List(TxOut)) -> Result(BitArray, SerializationError) {
  outputs
  |> list.try_map(serialize_output)
  |> result.map(bit_array.concat)
}

fn serialize_output(output: TxOut) -> Result(BitArray, SerializationError) {
  let TxOut(value, script_pubkey) = output
  
  use value_bytes <- result.try(serialize_u64_le(value))
  use script_bytes <- result.try(serialize_script(script_pubkey))
  
  Ok(bit_array.concat([value_bytes, script_bytes]))
}

fn serialize_script(script: Script) -> Result(BitArray, SerializationError) {
  use script_bytes <- result.try(serialize_script_elements(script))
  use length <- result.try(serialize_varint(bit_array.byte_size(script_bytes)))
  Ok(bit_array.concat([length, script_bytes]))
}

fn serialize_script_elements(elements: Script) -> Result(BitArray, SerializationError) {
  elements
  |> list.try_map(serialize_script_element)
  |> result.map(bit_array.concat)
}

fn serialize_script_element(element: script.ScriptElement) -> Result(BitArray, SerializationError) {
  case element {
    script.Op(opcode) -> Ok(serialize_opcode(opcode))
    script.Data(data) -> {
      let size = bit_array.byte_size(data)
      case size {
        s if s <= 75 -> Ok(bit_array.concat([<<s>>, data]))
        s if s <= 255 -> Ok(bit_array.concat([<<76>>, <<s>>, data]))
        s if s <= 65535 -> {
          use size_bytes <- result.try(serialize_u16_le(s))
          Ok(bit_array.concat([<<77>>, size_bytes, data]))
        }
        s -> {
          use size_bytes <- result.try(serialize_u32_le(s))
          Ok(bit_array.concat([<<78>>, size_bytes, data]))
        }
      }
    }
  }
}

fn serialize_opcode(opcode: script.ScriptOpCode) -> BitArray {
  case opcode {
    script.Op0 -> <<0>>
    script.Op1negate -> <<79>>
    script.Op1 -> <<81>>
    script.OpTrue -> <<81>>
    script.OpDup -> <<118>>
    script.OpHash160 -> <<169>>
    script.OpEqualverify -> <<136>>
    script.OpChecksig -> <<172>>
    script.OpEqual -> <<135>>
    script.OpCheckmultisig -> <<174>>
    script.OpReturn -> <<106>>
    script.OpPushdata1 -> <<76>>
    script.OpPushdata2 -> <<77>>
    script.OpPushdata4 -> <<78>>
  }
}

fn serialize_witness_data(inputs: List(TxIn)) -> Result(BitArray, SerializationError) {
  inputs
  |> list.try_map(serialize_witness)
  |> result.map(bit_array.concat)
}

fn serialize_witness(input: TxIn) -> Result(BitArray, SerializationError) {
  let witness_count = list.length(input.witness)
  use count_bytes <- result.try(serialize_varint(witness_count))
  use witness_items <- result.try(serialize_witness_items(input.witness))
  Ok(bit_array.concat([count_bytes, witness_items]))
}

fn serialize_witness_items(witness: List(BitArray)) -> Result(BitArray, SerializationError) {
  witness
  |> list.try_map(serialize_witness_item)
  |> result.map(bit_array.concat)
}

fn serialize_witness_item(item: BitArray) -> Result(BitArray, SerializationError) {
  let size = bit_array.byte_size(item)
  use size_bytes <- result.try(serialize_varint(size))
  Ok(bit_array.concat([size_bytes, item]))
}

fn serialize_varint(n: Int) -> Result(BitArray, SerializationError) {
  case n {
    n if n < 0 -> Error(InvalidInput)
    n if n < 253 -> Ok(<<n>>)
    n if n < 65536 -> {
      use bytes <- result.try(serialize_u16_le(n))
      Ok(bit_array.concat([<<253>>, bytes]))
    }
    n if n < 4294967296 -> {
      use bytes <- result.try(serialize_u32_le(n))
      Ok(bit_array.concat([<<254>>, bytes]))
    }
    n -> {
      use bytes <- result.try(serialize_u64_le(n))
      Ok(bit_array.concat([<<255>>, bytes]))
    }
  }
}

fn serialize_u16_le(n: Int) -> Result(BitArray, SerializationError) {
  case n >= 0 && n < 65536 {
    True -> Ok(<<n:16-little>>)
    False -> Error(InvalidInput)
  }
}

fn serialize_u32_le(n: Int) -> Result(BitArray, SerializationError) {
  case n >= 0 && n < 4294967296 {
    True -> Ok(<<n:32-little>>)
    False -> Error(InvalidInput)
  }
}

fn serialize_u64_le(n: Int) -> Result(BitArray, SerializationError) {
  case n >= 0 {
    True -> Ok(<<n:64-little>>)
    False -> Error(InvalidInput)
  }
}
