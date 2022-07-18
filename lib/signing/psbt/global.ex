defmodule BitcoinLib.Signing.Psbt.Global do
  defstruct []

  alias BitcoinLib.Signing.Psbt.Global

  def from_data(_data) do
    # data
    # |> extract_keypairs()
    # |> IO.inspect()

    %Global{}
  end

  # defp extract_keypairs(data) do
  #   extract_keypairs([], data)
  # end

  # defp extract_keypairs(keypairs, data) do

  # end
end
