defmodule BitcoinLib.Script.Opcodes.Crypto.Hash256 do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_HASH256
  Opcode 170
  Hex 0xaa
  Input in
  Output hash
  The input is hashed two times with SHA-256.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Crypto
  alias BitcoinLib.Script.Opcodes.Crypto.Hash256

  @type t :: Hash256

  @value 0xAA

  @doc """
  Returns 0xaa

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.Hash256.v()
      0xaa
  """
  @spec v() :: 0xAA
  def v do
    @value
  end

  @doc """
  Returns <<0xaa>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.Hash256.encode()
      <<0xaa>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The input is hashed two times with SHA-256.

  ## Examples
      iex> pub_key = <<0x0218fb7aff2c6cb9c25b7cd9aa0b9bdd712e5617f07cb0c96bdda0b44c25a5d25f::264>>
      ...> %BitcoinLib.Script.Opcodes.Crypto.Hash256{}
      ...> |> BitcoinLib.Script.Opcodes.Crypto.Hash256.execute([pub_key, 3])
      {:ok, [<<0x65bcba68347f2eddd470e427c957a7cee6406e041ffd80ed3f499cec868a8ac7::256>>, 3]}
  """
  @spec execute(Hash256.t(), [bitstring() | list()]) :: {:ok, [<<_::256>> | list()]}
  def execute(_opcode, []), do: {:error, "trying to execute OP_HASH256 on an empty stack"}

  def execute(_opcode, [first_element | remaining]) do
    hash = Crypto.double_sha256(first_element)

    {:ok, [hash | remaining]}
  end
end
