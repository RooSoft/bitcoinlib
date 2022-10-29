defmodule BitcoinLib.Key.HD.DerivationPath.Parser.CoinType do
  @moduledoc """
  Determines which coin type is being used, either bitcoin mainnet or bitcoin testnet.

  This is a hardened value.

  See: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#registered-coin-types
  """
  @bitcoin_coin_type "0'"
  @bitcoin_value 0
  @bitcoin_atom :bitcoin

  @bitcoin_testnet_coin_type "1'"
  @bitcoin_testnet_value 1
  @bitcoin_testnet_atom :bitcoin_testnet

  @doc """
  Converts a list of path levels managed up until the coin type, extracts
  the coin type and returns the remaining levels

  ## Examples
      iex> ["1'", "1", "2", "3"]
      ...> |> BitcoinLib.Key.HD.DerivationPath.Parser.CoinType.extract()
      {:ok, :bitcoin_testnet, ["1", "2", "3"]}
  """
  @spec extract(list()) :: {:ok, nil, []} | {:ok, integer(), list()} | {:error, binary()}
  def extract([]), do: {:ok, nil, []}
  def extract([@bitcoin_coin_type | rest]), do: {:ok, @bitcoin_atom, rest}
  def extract([@bitcoin_testnet_coin_type | rest]), do: {:ok, @bitcoin_testnet_atom, rest}
  def extract([coin_type | _rest]), do: {:error, "#{coin_type} is not a valid coin type"}

  def get_atom(@bitcoin_value), do: @bitcoin_atom
  def get_atom(@bitcoin_testnet_value), do: @bitcoin_testnet_atom
end
