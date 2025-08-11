import types/transaction.{type Transaction}

pub type Hash256 = BitArray
pub type BlockHash = BitArray

pub type BlockHeader {
  BlockHeader(
    version: Int,
    prev_block_hash: BlockHash,
    merkle_root: Hash256,
    timestamp: Int,
    bits: Int,
    nonce: Int,
  )
}

pub type Block {
  Block(header: BlockHeader, transactions: List(Transaction))
}