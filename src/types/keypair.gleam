pub type KeyPair {
  KeyPair(private_key: PrivateKey, public_key: PublicKey, compressed: Bool)
}

pub type ExtendedKey {
  ExtendedKey(
    network: Network,
    depth: Int,
    parent_fingerprint: BitArray,
    child_number: Int,
    chain_code: BitArray,
    key: BitArray,
    is_private: Bool,
  )
}
