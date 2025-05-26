pub fn new_transaction() -> Transaction {
  Transaction(version: 1, inputs: [], outputs: [], lock_time: 0)
}

pub fn add_input(
  tx: Transaction,
  txid: TxId,
  vout: Int,
  script_sig: Script,
  sequence: Int,
) -> Transaction {
  todo
}

pub fn add_witness_input(
  tx: Transaction,
  txid: TxId,
  vout: Int,
  script_sig: Script,
  sequence: Int,
  witness: List(BitArray),
) -> Transaction {
  todo
}

pub fn add_output(
  tx: Transaction,
  value: Satoshis,
  script_pubkey: Script,
) -> Transaction {
  todo
}

pub fn set_lock_time(tx: Transaction, lock_time: Int) -> Transaction {
  todo
}

pub fn set_version(tx: Transaction, version: Int) -> Transaction {
  todo
}

/// ==============
/// Serialization
/// ==============
pub fn serialize_transaction(tx: Transaction) -> BitArray {
  todo
}

pub fn serialize_transaction_legacy(
  tx: Transaction,
  version_bytes: BitArray,
) -> BitArray {
  todo
}

pub fn serialize_transaction_witness(
  tx: Transaction,
  version_bytes: BitArray,
) -> BitArray {
  let marker = <<0x00>>
  let flag = <<0x01>>
}

pub fn serialize_inputs(inputs: List(TxInput)) -> BitArray {
  todo
}

pub fn serialize_input(input: TxInput) -> BitArray {
  todo
}

pub fn serialize_outpoint(outpoint: OutPoint) -> BitArray {
  todo
}

pub fn serialize_outputs(outputs: List(TxOutput)) -> BitArray {
  todo
}

pub fn serialize_output(output: TxOutput) -> BitArray {
  todo
}

pub fn serialize_witness_data(inputs: List(TxInput)) -> BitArray {
  todo
}

pub fn serialize_witness_for_input(input: TxInput) -> BitArray {
  todo
}
/// ==============
/// Deserialization
/// =============
