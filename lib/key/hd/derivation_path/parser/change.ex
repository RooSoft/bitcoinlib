defmodule BitcoinLib.Key.HD.DerivationPath.Parser.Change do
  # https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#change
  @receiving_chain "0"
  @receiving_chain_value 0
  @receiving_chain_atom :receiving_chain
  @change_chain "1"
  @change_chain_value 1
  @change_chain_atom :change_chain

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
