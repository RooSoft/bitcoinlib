defmodule BitcoinLib.Signing.Psbt.Global.Version do
  @moduledoc """
  A partially signed bitcoin transaction's version number
  """

  defstruct [:value]

  alias BitcoinLib.Signing.Psbt.Global.Version

  # TODO: document
  def parse(<<version::little-32>>) do
    %Version{value: version}
  end

  def parse(_) do
    {:error, "malformed PSBT version number"}
  end
end
