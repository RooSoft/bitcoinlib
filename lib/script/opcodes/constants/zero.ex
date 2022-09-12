defmodule BitcoinLib.Script.Opcodes.Constants.Zero do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_0, OP_FALSE
  Opcode 0
  Hex 0x00
  Input Nothing.
  Output (empty value)
  Description An empty array of bytes is pushed onto the stack. (This is not a no-op: an item is added to the stack.)
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Zero

  @value 0x00

  def v do
    @value
  end

  def encode() do
    <<@value::8>>
  end

  def execute(%Zero{}, remaining) do
    {:ok, remaining}
  end
end
