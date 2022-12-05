defmodule BitcoinLib.Script.Opcodes.Crypto.CheckSigVerify do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_CHECKSIGVERIFY
  Opcode 173
  Hex 0xad
  Input sig pubkey
  Output Nothing / fail
  Description Same as OP_CHECKSIG, but OP_VERIFY is executed afterward.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Crypto.CheckSigVerify

  @type t :: CheckSigVerify

  @value 0xAD

  @doc """
  Returns 0xad

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.CheckSigVerify.v()
      0xad
  """
  @spec v() :: 0xAD
  def v do
    @value
  end

  @doc """
  Returns <<0xad>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.CheckSigVerify.encode()
      <<0xad>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  NOT IMPLEMENTED YET
  """
  @spec execute(CheckSigVerify.t(), list()) :: {:ok, [list()]} | {:error, binary()}
  def execute(%CheckSigVerify{}, []) do
    throw("OP_CHECKSIGVERIFY execution has not ben implemented yet")
  end
end
