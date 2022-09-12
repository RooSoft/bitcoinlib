defmodule BitcoinLib.Script.Opcodes.FlowControl.Return do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_RETURN
  Opcode 106
  Hex 0x6a
  Input Nothing
  Output fail
  Description
    Marks transaction as invalid. Since bitcoin 0.9, a standard way of attaching extra data
    to transactions is to add a zero-value output with a scriptPubKey consisting of OP_RETURN
    followed by data. Such outputs are provably unspendable and specially discarded from
    storage in the UTXO set, reducing their cost to the network. Since 0.12, standard relay
    rules allow a single output with OP_RETURN, that contains any sequence of push statements
    (or OP_RESERVED[1]) after the OP_RETURN provided the total scriptPubKey length is at most
    83 bytes.

  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.FlowControl.Return

  @value 0x6A

  def v do
    @value
  end

  def execute(_opcode, []), do: {:error, "trying to execute OP_VERIFY on an empty stack"}

  def execute(%Return{}, []) do
    throw("OP_CHECKMULTISIG execution has not ben implemented yet")
  end
end
