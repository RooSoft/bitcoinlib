defmodule BitcoinLib.Script.Opcodes.Crypto.Hash160 do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_HASH160
  Opcode 169
  Hex 0xa9
  Input in
  Output hash
  Description The input is hashed twice: first with SHA-256 and then with RIPEMD-160.
  """

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
