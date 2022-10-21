defmodule BitcoinLib.Signing.Psbt.Input.OutputIndex do
  defstruct [:value]

  alias BitcoinLib.Signing.Psbt.Input.OutputIndex

  # TODO: document
  def parse(<<value::unsigned-little-32>>) do
    %OutputIndex{
      value: value
    }
  end

  def parse(_) do
    %{error: "invalid output index"}
  end
end
