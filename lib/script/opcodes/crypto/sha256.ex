defmodule BitcoinLib.Script.Opcodes.Crypto.Sha256 do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_SHA256
  Opcode 168
  Hex 0xa8
  Input in
  Output hash
  The input is hashed using SHA-256.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Crypto
  alias BitcoinLib.Script.Opcodes.Crypto.Sha256

  @type t :: Sha256

  @value 0xA8

  @doc """
  Returns 0xa8

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.Sha256.v()
      0xa8
  """
  @spec v() :: 0xA8
  def v do
    @value
  end

  @doc """
  Returns <<0xa8>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.Sha256.encode()
      <<0xa8>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The input is hashed using SHA-256.

  ## Examples
      iex> pub_key = <<0x0218fb7aff2c6cb9c25b7cd9aa0b9bdd712e5617f07cb0c96bdda0b44c25a5d25f::264>>
      ...> %BitcoinLib.Script.Opcodes.Crypto.Sha256{}
      ...> |> BitcoinLib.Script.Opcodes.Crypto.Sha256.execute([pub_key, 3])
      {:ok, [<<0x01e9a3394b9fdf95aa04dcb91bf540aae4196bf8c550d9be4c2d0ff94fd505bd::256>>, 3]}
  """
  @spec execute(Sha256.t(), [<<_::264>> | list()]) :: {:ok, [<<_::256>> | list()]}
  def execute(_opcode, []), do: {:error, "trying to execute OP_SHA256 on an empty stack"}

  def execute(_opcode, [first_element | remaining]) do
    hash = Crypto.sha256(first_element)

    {:ok, [hash | remaining]}
  end
end
