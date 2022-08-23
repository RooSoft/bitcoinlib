defmodule BitcoinLib.Script.Opcodes.Constants.One do
  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.One

  @value 0x51

  def v do
    @value
  end

  def execute(%One{}, remaining) do
    {:ok, remaining}
  end
end
