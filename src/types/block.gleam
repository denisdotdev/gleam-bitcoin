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
