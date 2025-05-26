pub type AddressType {
  P2PKH
  P2SH
  P2WPKH
  P2WSH
  P2TR
}

pub type Address {
  Address(data: BitArray, address_type: AddressType, network: Network)
}
