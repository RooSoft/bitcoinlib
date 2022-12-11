defmodule BitcoinLib.Key.HD.DerivationPath.Parser.Network do
  @moduledoc """
  Determines which network is being used, either mainnet or testnet.

  This is a hardened value.

  See: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#registered-coin-types
  """

  @mainnet_network "0'"
  @mainnet_value 0
  @mainnet_atom :mainnet

  @testnet_network "1'"
  @testnet_value 1
  @testnet_atom :testnet

  @doc """
  Converts a list of path levels managed up until the network, extracts
  the network and returns the remaining levels

  ## Examples
      iex> ["1'", "1", "2", "3"]
      ...> |> BitcoinLib.Key.HD.DerivationPath.Parser.Network.extract()
      {:ok, :testnet, ["1", "2", "3"]}
  """
  @spec extract(list()) :: {:ok, nil, []} | {:ok, atom(), list()} | {:error, binary()}
  def extract([]), do: {:ok, nil, []}
  def extract([@mainnet_network | rest]), do: {:ok, @mainnet_atom, rest}
  def extract([@testnet_network | rest]), do: {:ok, @testnet_atom, rest}

  def extract([network | _rest]) do
    message =
      case String.ends_with?(network, "'") do
        true -> "#{network} is an invalid network"
        false -> "network must be a hardened value"
      end

    {:error, message}
  end

  def get_atom(@mainnet_value), do: @mainnet_atom
  def get_atom(@testnet_value), do: @testnet_atom
end
