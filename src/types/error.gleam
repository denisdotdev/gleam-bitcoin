pub type BitcoinError {
  InvalidTransaction(String)
  InvalidScript(String)
  InvalidPublicKey(String)
}
