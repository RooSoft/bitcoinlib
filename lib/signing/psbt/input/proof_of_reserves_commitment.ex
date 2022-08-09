defmodule BitcoinLib.Signing.Psbt.Input.ProofOfReservesCommitment do
  defstruct [:value]

  alias BitcoinLib.Signing.Psbt.Input.ProofOfReservesCommitment

  def parse(<<value::binary>>) do
    %ProofOfReservesCommitment{
      value: value
    }
  end
end
