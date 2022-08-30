defmodule BitcoinLib.Script.Opcodes.Crypto.Hash160 do
  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Crypto

  @value 0xA9

  def v do
    @value
  end

  def encode() do
    <<@value::8>>
  end

  def execute(_opcode, []), do: {:error, "trying to execute OP_HASH160 on an empty stack"}

  def execute(_opcode, [first_element | remaining]) do
    hash = Crypto.hash160(first_element)

    {:ok, [hash | remaining]}
  end
end
