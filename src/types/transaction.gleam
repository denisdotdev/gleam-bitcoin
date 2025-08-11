import types/script.{type Script}

pub type OutPoint {
  OutPoint(txid: BitArray, vout: Int)
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

pub type Transaction {
  Transaction(
    version: Int,
    inputs: List(TxIn),
    outputs: List(TxOut),
    lock_time: Int,
  )
}
