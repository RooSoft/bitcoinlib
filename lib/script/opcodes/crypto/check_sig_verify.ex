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

  @value 0xAD

  def v do
    @value
  end

  @spec execute(%CheckSigVerify{}, list()) :: {:ok, [list()]} | {:error, binary()}
  def execute(%CheckSigVerify{}, []) do
    throw("OP_CHECKSIGVERIFY execution has not ben implemented yet")
  end
end
