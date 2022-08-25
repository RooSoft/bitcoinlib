defmodule BitcoinLib.Script.Opcodes.Crypto.CheckSigVerify do
  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Crypto.CheckSigVerify

  @value 0xAD

  def v do
    @value
  end

  @spec execute(%CheckSigVerify{}, list()) :: :ok | :error
  def execute(%CheckSigVerify{}, []) do
    throw("OP_CHECKSIGVERIFY execution has not ben implemented yet")
  end
end
