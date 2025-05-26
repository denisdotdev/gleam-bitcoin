// Unspent Transaction Output
pub type UTXO {
  UTXO(
    outpoint: OutPoint,
    output: TxOutput,
    height: Option(Int),
    confirmations: Int,
  )
}

pub type FeeRate =
  Int

pub type Priority {
  Low
  Medium
  High
  Custom(FeeRate)
}
