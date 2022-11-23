defmodule BitcoinLib.Script.Opcodes.Crypto.Ripemd160 do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_Ripemd160
  Opcode 166
  Hex 0xa6
  Input in
  Output hash
  The input is hashed using RIPEMD-160.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Crypto
  alias BitcoinLib.Script.Opcodes.Crypto.Ripemd160

  @value 0xA6

  @doc """
  Returns 0xa6

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.Ripemd160.v()
      0xa6
  """
  @spec v() :: 0xA6
  def v do
    @value
  end

  @doc """
  Returns <<0xa6>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.Ripemd160.encode()
      <<0xa6>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The input is hashed using RIPEMD-160.

  ## Examples
      iex> pub_key = <<0x0218fb7aff2c6cb9c25b7cd9aa0b9bdd712e5617f07cb0c96bdda0b44c25a5d25f::264>>
      ...> %BitcoinLib.Script.Opcodes.Crypto.Ripemd160{}
      ...> |> BitcoinLib.Script.Opcodes.Crypto.Ripemd160.execute([pub_key, 3])
      {:ok, [<<0xafca2e6d573c88813ac8f8af67b26a8b6e49441e::160>>, 3]}
  """
  @spec execute(%Ripemd160{}, [<<_::264>> | list()]) :: {:ok, [<<_::160>> | list()]}
  def execute(_opcode, []), do: {:error, "trying to execute OP_RIPEMD160 on an empty stack"}

  def execute(_opcode, [first_element | remaining]) do
    hash = Crypto.ripemd160(first_element)

    {:ok, [hash | remaining]}
  end
end
