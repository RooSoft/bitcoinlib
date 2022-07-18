defmodule BitcoinLib.Signing.Psbt.Outputs do
  defstruct []

  alias BitcoinLib.Signing.Psbt.Outputs

  def from_data(_data) do
    %Outputs{}
  end
end
