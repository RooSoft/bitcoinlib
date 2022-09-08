defmodule BitcoinLib.Key.HD.DerivationPath.Parser.CoinType do
  # https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#registered-coin-types
  @bitcoin_coin_type_value 0
  @bitcoin_testnet_coin_type_value 1

  @bitcoin_atom :bitcoin
  @bitcoin_testnet_atom :bitcoin_testnet

  @invalid_atom :invalid

  @doc """
  Converts an integer into an atom representing the bitcoin chain

  ## Examples
    iex> BitcoinLib.Key.HD.DerivationPath.Parser.CoinType.parse(0)
    :bitcoin
  """
  @spec parse(integer()) :: :bitcoin | :bitcoin_testnet | :invalid
  def parse(nil), do: nil

  def parse(value) when is_integer(value) do
    case value do
      @bitcoin_coin_type_value -> @bitcoin_atom
      @bitcoin_testnet_coin_type_value -> @bitcoin_testnet_atom
      _ -> @invalid_atom
    end
  end

  def parse(hash), do: hash
end
