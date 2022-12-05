defmodule BitcoinLib.Signing.Psbt.Input.SighashType do
  @moduledoc """
  Sighash type part of a partially signed bitcoin transaction's input
  """

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
