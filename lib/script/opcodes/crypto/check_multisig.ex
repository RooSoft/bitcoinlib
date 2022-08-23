defmodule BitcoinLib.Script.Opcodes.Crypto.CheckMultiSig do
  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Crypto.CheckMultiSig

  @value 0xAE

  def v do
    @value
  end

  def execute(%CheckMultiSig{}, []) do
    throw("OP_CHECKMULTISIG execution has not ben implemented yet")
  end
end
