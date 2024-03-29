defmodule BitcoinLib.Key.HD.DerivationPath do
  @moduledoc """
  Can parse derivation paths string format into a native format

  m / purpose' / network' / account' / change / address_index

  Inspired by

    https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
    https://learnmeabitcoin.com/technical/derivation-paths
  """

  @enforce_keys [:type]
  defstruct [:type, :purpose, :network, :account, :change, :address_index]

  alias BitcoinLib.Key.HD.DerivationPath
  alias BitcoinLib.Key.HD.DerivationPath.{Parser, PathValues}
  alias BitcoinLib.Key.HD.DerivationPath.Parser.{Type, Purpose, Network, Change}

  @type t :: DerivationPath

  @hardened :math.pow(2, 31) |> trunc

  @doc """
  Transforms a derivation path string into an elixir structure

  ## Examples
      iex> "m / 44' / 1' / 2' / 1 / 4"
      ...> |> BitcoinLib.Key.HD.DerivationPath.parse()
      { :ok,
        %BitcoinLib.Key.HD.DerivationPath{
          type: :private,
          purpose: :bip44,
          network: :testnet,
          account: 2,
          change: :change_chain,
          address_index: 4
        }
      }
  """
  @spec parse(binary()) :: {:ok, DerivationPath.t()}
  def parse(derivation_path) do
    derivation_path
    |> Parser.parse_valid_derivation_path()
  end

  @doc """
  Retruns a %DerivationPath from a set of parameters, with these values potentially missing:
  network, account, change, address_index

  ## Examples
      iex> BitcoinLib.Key.HD.DerivationPath.from_values("M", 0x80000054, 0x80000000, 0x80000000, 0, 0)
      %BitcoinLib.Key.HD.DerivationPath{
        type: :public,
        purpose: :bip84,
        network: :mainnet,
        account: 0,
        change: :receiving_chain,
        address_index: 0
      }
  """
  @spec from_values(
          binary(),
          integer(),
          integer() | nil,
          integer() | nil,
          integer() | nil,
          integer() | nil
        ) ::
          DerivationPath.t()
  def from_values(
        type,
        purpose,
        network \\ nil,
        account \\ nil,
        change \\ nil,
        address_index \\ nil
      ) do
    %DerivationPath{
      type: parse_type(type),
      purpose: parse_purpose(purpose),
      network: parse_network(network),
      account: convert_hardened_account(account),
      change: parse_change(change),
      address_index: address_index
    }
  end

  @doc """
  Turns a list of path values into a %DerivationPath{}

  ## Examples
      iex> ["m", 0x80000054, 0x80000000, 0x80000005]
      ...> |> BitcoinLib.Key.HD.DerivationPath.from_list
      %BitcoinLib.Key.HD.DerivationPath{
        type: :private,
        purpose: :bip84,
        network: :mainnet,
        account: 5
      }
  """
  @spec from_list(list()) :: DerivationPath.t()
  def from_list(values_list) do
    %PathValues{
      type: type,
      purpose: purpose,
      network: network,
      account: account,
      change: change,
      address_index: address_index
    } = PathValues.from_list(values_list)

    from_values(type, purpose, network, account, change, address_index)
  end

  defp parse_type(type) do
    Type.get_atom(type)
  end

  defp parse_purpose(purpose) when is_integer(purpose) do
    Purpose.get_atom(purpose - @hardened)
  end

  defp parse_network(nil), do: nil

  defp parse_network(network) do
    Network.get_atom(network - @hardened)
  end

  defp convert_hardened_account(nil), do: nil

  defp convert_hardened_account(hardened_account) when is_integer(hardened_account) do
    hardened_account - @hardened
  end

  defp parse_change(nil), do: nil

  defp parse_change(change_chain) do
    Change.get_atom(change_chain)
  end
end
