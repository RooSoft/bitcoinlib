defmodule BitcoinLib.Signing.Psbt.Input.ProofOfReservesCommitment do
  defstruct [:value]

  alias BitcoinLib.Signing.Psbt.Input.ProofOfReservesCommitment
  alias BitcoinLib.Signing.Psbt.{Keypair}

  def parse(%Keypair{key: _, value: <<value::bitstring>>}) do
    %ProofOfReservesCommitment{
      value: value
    }
  end
end
