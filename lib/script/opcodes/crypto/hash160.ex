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

  @doc """
  Returns 0xa9

  ## Examples
    iex> BitcoinLib.Script.Opcodes.Crypto.Hash160.v()
    0xa9
  """
  @spec v() :: 0xA9
  def v do
    @value
  end

  @doc """
  Returns <<0xa9>>

  ## Examples
    iex> BitcoinLib.Script.Opcodes.Crypto.Hash160.encode()
    <<0xa9>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The input is hashed twice: first with SHA-256 and then with RIPEMD-160.

  ## Examples
    iex> pub_key = <<0x0218fb7aff2c6cb9c25b7cd9aa0b9bdd712e5617f07cb0c96bdda0b44c25a5d25f::264>>
    ...> %BitcoinLib.Script.Opcodes.Crypto.Hash160{}
    ...> |> BitcoinLib.Script.Opcodes.Crypto.Hash160.execute([pub_key, 3])
    {:ok, [<<0x17cdc02e31846f9e7c25952700f53e9752a0a3c2::160>>, 3]}
  """
  def execute(_opcode, []), do: {:error, "trying to execute OP_HASH160 on an empty stack"}

  def execute(_opcode, [first_element | remaining]) do
    hash = Crypto.hash160(first_element)

    {:ok, [hash | remaining]}
  end
end
