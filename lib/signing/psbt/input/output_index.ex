defmodule BitcoinLib.Signing.Psbt.Input.OutputIndex do
  @moduledoc """
  An output index in a partially signed bitcoin transaction's input
  """

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
