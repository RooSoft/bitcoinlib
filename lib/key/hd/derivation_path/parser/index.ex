defmodule BitcoinLib.Key.HD.DerivationPath.Parser.Index do
  @moduledoc """
  Addresses are numbered from index 0 in sequentially increasing manner. This number is used as child index in BIP32 derivation.

  Public derivation is used at this level.

  See: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#index
  """

  @doc """
  Converts a list of path levels managed up until the index value, extracts
  the index

  ## Examples
      iex> ["2"]
      ...> |> BitcoinLib.Key.HD.DerivationPath.Parser.Index.extract()
      {:ok, 2}
  """
  @spec extract(list()) :: {:ok, nil} | {:ok, integer()} | {:error, binary()}
  def extract([]), do: {:ok, nil}

  def extract([index]) do
    index
    |> Integer.parse()
    |> convert()
  end

  defp convert({index, ""}), do: {:ok, index}
  defp convert({_index, _remainder}), do: {:error, "index should be an integer"}
  defp convert(:error), do: {:error, "index should be a valid integer"}
end
