defmodule BitcoinLib.Script.Opcodes.Crypto.CheckMultiSig do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_CHECKMULTISIG
  Opcode 174
  Hex 0xae
  Input x sig1 sig2 ... <number of signatures> pub1 pub2 <number of public keys>
  Output True / False
  Description
    Compares the first signature against each public key until it finds an ECDSA match.
    Starting with the subsequent public key, it compares the second signature against
    each remaining public key until it finds an ECDSA match. The process is repeated until
    all signatures have been checked or not enough public keys remain to produce a successful
    result. All signatures need to match a public key. Because public keys are not checked
    again if they fail any signature comparison, signatures must be placed in the scriptSig
    using the same order as their corresponding public keys were placed in the scriptPubKey
    or redeemScript. If all signatures are valid, 1 is returned, 0 otherwise. Due to a bug,
    one extra unused value is removed from the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Crypto.CheckMultiSig

  @value 0xAE

  @doc """
  Returns 0xaf

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.CheckMultiSig.v()
      0xae
  """
  @spec v() :: 0xAE
  def v do
    @value
  end

  @doc """
  NOT IMPLEMENTED YET
  """
  def execute(%CheckMultiSig{}, []) do
    throw("OP_CHECKMULTISIG execution has not ben implemented yet")
  end
end
