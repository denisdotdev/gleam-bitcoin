pub type SigHashType {
  SIGHASH_ALL
  SIGHASH_NONE
  SIGHASH_SINGLE
  SIGHASH_ALL_ANYONECANPAY
  SIGHASH_NONE_ANYONECANPAY
  SIGHASH_SINGLE_ANYONECANPAY
}

pub type SignatureWithType {
  SignatureWithType(signature: Signature, sighash_type: SigHashType)
}
