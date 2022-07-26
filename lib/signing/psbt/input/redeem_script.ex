defmodule BitcoinLib.Signing.Psbt.Input.RedeemScript do
  defstruct [:script]

  alias BitcoinLib.Signing.Psbt.Input.RedeemScript

  def parse(data) do
    %RedeemScript{
      script: Binary.to_hex(data)
    }
  end
end
