defmodule BitcoinLib.Signing.Psbt.Input.SighashType do
  defstruct [:value]

  alias BitcoinLib.Signing.Psbt.Input.SighashType

  def parse(<<value::little-32>>) do
    %SighashType{
      value: value
    }
  end
end
