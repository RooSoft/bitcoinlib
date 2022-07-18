defmodule BitcoinLib.Signing.Psbt.Inputs do
  defstruct []

  alias BitcoinLib.Signing.Psbt.Inputs

  def from_data(_data) do
    %Inputs{}
  end
end
