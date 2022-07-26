defmodule BitcoinLib.Signing.Psbt.Input.WitnessScript do
  defstruct [:script]

  alias BitcoinLib.Signing.Psbt.Input.WitnessScript

  def parse(data) do
    %WitnessScript{
      script: Binary.to_hex(data)
    }
  end
end
