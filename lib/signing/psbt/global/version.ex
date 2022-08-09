defmodule BitcoinLib.Signing.Psbt.Global.Version do
  defstruct [:value]

  alias BitcoinLib.Signing.Psbt.Global.Version

  def parse(<<version::little-32>>) do
    %Version{value: version}
  end

  def parse(_) do
    {:error, "malformed PSBT version number"}
  end
end
