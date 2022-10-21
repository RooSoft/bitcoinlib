defmodule BitcoinLib.Signing.Psbt.Input.SighashType do
  defstruct [:value]

  alias BitcoinLib.Signing.Psbt.Input.SighashType

  # TODO: document
  def parse(<<value::little-32>>) do
    %SighashType{
      value: value
    }
  end

  def parse(_) do
    %{error: "invalid sighash type"}
  end
end
