defmodule BitcoinLib.Script.Opcodes.Crypto.Sha1 do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_SHA1
  Opcode 161
  Hex 0xa7
  Input in
  Output hash
  The input is hashed using SHA-1.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Crypto
  alias BitcoinLib.Script.Opcodes.Crypto.Sha1

  @type t :: Sha1

  @value 0xA7

  @doc """
  Returns 0xa7

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.Sha1.v()
      0xa7
  """
  @spec v() :: 0xA7
  def v do
    @value
  end

  @doc """
  Returns <<0xa7>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.Sha1.encode()
      <<0xa7>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The input is hashed using SHA-1.

  ## Examples
      iex> pub_key = <<0x0218fb7aff2c6cb9c25b7cd9aa0b9bdd712e5617f07cb0c96bdda0b44c25a5d25f::264>>
      ...> %BitcoinLib.Script.Opcodes.Crypto.Sha1{}
      ...> |> BitcoinLib.Script.Opcodes.Crypto.Sha1.execute([pub_key, 3])
      {:ok, [<<0x148bdd3eb072846d9828b2042e8391e4f6614ad2::160>>, 3]}
  """
  @spec execute(Sha1.t(), [<<_::264>> | list()]) :: {:ok, [<<_::160>> | list()]}
  def execute(_opcode, []), do: {:error, "trying to execute OP_SHA1 on an empty stack"}

  def execute(_opcode, [first_element | remaining]) do
    hash = Crypto.sha1(first_element)

    {:ok, [hash | remaining]}
  end
end
