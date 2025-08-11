pub type ScriptOpCode {
  Op0
  OpPushdata1
  OpPushdata2
  OpPushdata4
  Op1negate
  Op1
  OpTrue
  OpDup
  OpHash160
  OpEqualverify
  OpChecksig
  OpEqual
  OpCheckmultisig
  OpReturn
}

pub type ScriptElement {
  Op(ScriptOpCode)
  Data(BitArray)
}

pub type Script = List(ScriptElement)
