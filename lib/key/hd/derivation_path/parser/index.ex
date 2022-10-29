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
    with {:ok, index} <- validate_non_hardened(index),
         {integer_index, ""} <- Integer.parse(index) do
      {:ok, integer_index}
    else
      {:error, message} -> {:error, message}
      :error -> {:error, "index should be a valid integer"}
    end
  end

  defp validate_non_hardened(index) do
    case String.ends_with?(index, "'") do
      true -> {:error, "account number must NOT be a hardened value"}
      false -> {:ok, index}
    end
  end
end
