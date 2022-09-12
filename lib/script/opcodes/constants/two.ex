defmodule BitcoinLib.Script.Opcodes.Constants.Two do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_2
  Opcode 82
  Hex 0x52
  Input Nothing.
  Output 2
  Description The number 2 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Two

  @value 0x52

  def v do
    @value
  end

  def encode() do
    <<@value::8>>
  end

  def execute(%Two{}, remaining) do
    {:ok, remaining}
  end
end
