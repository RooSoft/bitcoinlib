defmodule BitcoinLib.Key.HD.DerivationPath.Parser.Purpose do
  @moduledoc """
  Determines which address space is being used, either bip44, bip49 or bip84.

  This is a hardened value.

  See: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#purpose
  """

  # https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#purpose
  @bip44_purpose "44'"
  @bip44_value 44
  @bip44_atom :bip44

  # https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki#public-key-derivation
  @bip49_purpose "49'"
  @bip49_value 49
  @bip49_atom :bip49

  # https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#public-key-derivation
  @bip84_purpose "84'"
  @bip84_value 84
  @bip84_atom :bip84

  @doc """
  Converts a list of path levels managed up until the purpose value, extracts
  the purpose and returns the remaining levels

  ## Examples
      iex> ["84'", "0", "1", "2", "3"]
      ...> |> BitcoinLib.Key.HD.DerivationPath.Parser.Purpose.extract()
      {:ok, :bip84, ["0", "1", "2", "3"]}
  """
  @spec extract(list()) :: {:ok, nil, []} | {:ok, atom(), list()} | {:error, binary()}
  def extract([]), do: {:ok, nil, []}

  def extract([purpose | rest]) do
    purpose
    |> String.trim()
    |> convert(rest)
  end

  def get_atom(@bip44_value), do: @bip44_atom
  def get_atom(@bip49_value), do: @bip49_atom
  def get_atom(@bip84_value), do: @bip84_atom
  def get_atom(unknown), do: {:error, "#{unknown} is an invalid purpose"}

  defp convert(@bip44_purpose, rest), do: {:ok, @bip44_atom, rest}
  defp convert(@bip49_purpose, rest), do: {:ok, @bip49_atom, rest}
  defp convert(@bip84_purpose, rest), do: {:ok, @bip84_atom, rest}
  defp convert(purpose, _rest), do: {:error, "#{purpose} is not a valid purpose"}
end
