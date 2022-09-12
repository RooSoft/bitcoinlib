defmodule BitcoinLib.Script.Opcodes.Constants.One do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_1, OP_TRUE
  Opcode 81
  Hex 0x51
  Input Nothing.
  Output 1
  Description The number 1 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.One

  @value 0x51

  def v do
    @value
  end

  def encode() do
    <<@value::8>>
  end

  def execute(%One{}, remaining) do
    {:ok, remaining}
  end
end
