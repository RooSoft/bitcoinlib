defmodule BitcoinLib.Signing.Psbt.Global do
  defstruct []

  alias BitcoinLib.Signing.Psbt.Global

  def from_data(_data) do
    %Global{}
  end
end
