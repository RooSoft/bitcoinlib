defmodule BitcoinLib.Script.Opcodes.Crypto.CheckMultiSigVerify do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_CHECKMULTISIGVERIFY
  Opcode 175
  Hex 0xaf
  Input x sig1 sig2 ... <number of signatures> pub1 pub2 ... <number of public keys>
  Output Nothing / fail
  Description Same as OP_CHECKMULTISIG, but OP_VERIFY is executed afterward.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Crypto.CheckMultiSigVerify

  @value 0xAF

  @doc """
  Returns 0xaf

  ## Examples
    iex> BitcoinLib.Script.Opcodes.Crypto.CheckMultiSigVerify.v()
    0xaf
  """
  @spec v() :: 0xAF
  def v do
    @value
  end

  @doc """
  NOT IMPLEMENTED YET
  """
  def execute(%CheckMultiSigVerify{}, []) do
    throw("OP_CHECKMULTISIGVERIFY execution has not ben implemented yet")
  end
end
