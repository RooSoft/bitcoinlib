defmodule BitcoinLib.Script.Opcodes.Stack.Dup do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_DUP
  Opcode 118
  Hex 0x76
  Input x
  Output x x
  Description Duplicates the top stack item.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  @value 0x76

  def v do
    @value
  end

  def encode() do
    <<@value::8>>
  end

  def execute(_opcode, []), do: {:error, "trying to execute OP_DUP on an empty stack"}

  def execute(_opcode, [first_element | _] = stack) do
    {:ok, [first_element | stack]}
  end
end
