defmodule BitcoinLib.Key.HD.DerivationPath.Parser.Change do
  # https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#change
  @receiving_chain_value 0
  @receiving_chain_atom :receiving_chain
  @change_chain_value 1
  @change_chain_atom :change_chain

  @invalid_atom :invalid

  @doc """
  Converts an integer into an atom representing the receiving or change chain

  ## Examples
      iex> BitcoinLib.Key.HD.DerivationPath.Parser.Change.parse(0)
      :receiving_chain
  """
  @spec parse(integer()) :: :receiving_chain | :change_chain | :invalid
  def parse(value) when is_integer(value) do
    case value do
      @receiving_chain_value -> @receiving_chain_atom
      @change_chain_value -> @change_chain_atom
      _ -> @invalid_atom
    end
  end

  def parse(hash) do
    hash
  end
end
