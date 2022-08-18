defmodule BitcoinLib.Script.Opcodes.Constants.Two do
  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Two

  @value 0x52

  def v do
    @value
  end

  def execute(%Two{}, remaining) do
    {:ok, remaining}
  end
end
