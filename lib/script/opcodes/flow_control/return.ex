defmodule BitcoinLib.Script.Opcodes.FlowControl.Return do
  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.FlowControl.Return

  @value 0x6A

  def v do
    @value
  end

  def execute(_opcode, []), do: {:error, "trying to execute OP_VERIFY on an empty stack"}

  def execute(%Return{}, []) do
    throw("OP_CHECKMULTISIG execution has not ben implemented yet")
  end
end
