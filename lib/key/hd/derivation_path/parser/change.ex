defmodule BitcoinLib.Key.HD.DerivationPath.Parser.Change do
  @moduledoc """
  Determines which change chain is being used, either receiving or change.

  This is a hardened value.

  See: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#change
  """

  @receiving_chain "0"
  @receiving_chain_value 0
  @receiving_chain_atom :receiving_chain

  @change_chain "1"
  @change_chain_value 1
  @change_chain_atom :change_chain

  @doc """
  Converts a list of path levels managed up until the change chain, extracts
  the change chain and returns the remaining levels

  ## Examples
      iex> ["1", "2", "3"]
      ...> |> BitcoinLib.Key.HD.DerivationPath.Parser.Change.extract()
      {:ok, :change_chain, ["2", "3"]}
  """
  @spec extract(list()) :: {:ok, nil, []} | {:ok, atom(), list()} | {:error, binary()}
  def extract([]), do: {:ok, nil, []}

  def extract([change_chain | rest]) do
    change_chain
    |> String.trim()
    |> convert(rest)
  end

  def get_atom(@receiving_chain_value), do: @receiving_chain_atom
  def get_atom(@change_chain_value), do: @change_chain_atom

  defp convert(@receiving_chain, rest), do: {:ok, @receiving_chain_atom, rest}
  defp convert(@change_chain, rest), do: {:ok, @change_chain_atom, rest}
  defp convert(change_chain, _rest), do: {:error, "#{change_chain} is not a valid change chain"}
end
