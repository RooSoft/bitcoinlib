defmodule BitcoinLib.Script.Opcodes.Crypto.CheckMultiSigVerify do
  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Crypto.CheckMultiSigVerify

  @value 0xAF

  def v do
    @value
  end

  def execute(%CheckMultiSigVerify{}, []) do
    throw("OP_CHECKMULTISIGVERIFY execution has not ben implemented yet")
  end
end
