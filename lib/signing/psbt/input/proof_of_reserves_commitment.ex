defmodule BitcoinLib.Signing.Psbt.Input.ProofOfReservesCommitment do
  @moduledoc """
  The proof of reserves commitment of a partially signed bitcoin transaction's input
  """

  defstruct [:value]

  alias BitcoinLib.Signing.Psbt.Input.ProofOfReservesCommitment
  alias BitcoinLib.Signing.Psbt.{Keypair}

  # TODO: document
  def parse(%Keypair{key: _, value: <<value::bitstring>>}) do
    %ProofOfReservesCommitment{
      value: value
    }
  end
end
