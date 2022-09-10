defmodule BitcoinLib.Key.HD.DerivationPath do
  @moduledoc """
  Can parse derivation paths string format into a native format

  m / purpose' / coin_type' / account' / change / address_index

  Inspired by

    https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
    https://learnmeabitcoin.com/technical/derivation-paths
  """

  @enforce_keys [:type]
  defstruct [:type, :purpose, :coin_type, :account, :change, :address_index]

  alias BitcoinLib.Key.HD.DerivationPath
  alias BitcoinLib.Key.HD.DerivationPath.{Parser, PathValues}
  alias BitcoinLib.Key.HD.DerivationPath.Parser.{Purpose, CoinType}

  @hardened 0x80000000

  @doc """
  Transforms a derivation path string into an elixir structure

  ## Examples
    iex> "m / 44' / 1' / 2' / 1 / 4"
    ...> |> BitcoinLib.Key.HD.DerivationPath.parse()
    { :ok,
      %BitcoinLib.Key.HD.DerivationPath{
        type: :private,
        purpose: :bip44,
        coin_type: :bitcoin_testnet,
        account: %BitcoinLib.Key.HD.DerivationPath.Level{hardened?: true, value: 2},
        change: :change_chain,
        address_index: %BitcoinLib.Key.HD.DerivationPath.Level{hardened?: false, value: 4}
      }
    }
  """
  @spec parse(binary()) :: {:ok, %BitcoinLib.Key.HD.DerivationPath{}}
  def parse(derivation_path) do
    derivation_path
    |> validate
    |> Parser.maybe_parse_valid_derivation_path()
  end

  @doc """
  Retruns a %DerivationPath from a set of parameters, with these values potentially missing:
  coin_type, account, change, address_index

  ## Examples
    iex> BitcoinLib.Key.HD.DerivationPath.from_values("M", 0x80000054, 0x80000000, 0x80000000, 0, 0)
    %BitcoinLib.Key.HD.DerivationPath{
      type: "M",
      purpose: :bip84,
      coin_type: :bitcoin,
      account: 0x80000000,
      change: 0,
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
          %DerivationPath{}
  def from_values(
        type,
        purpose,
        coin_type \\ nil,
        account \\ nil,
        change \\ nil,
        address_index \\ nil
      ) do
    %DerivationPath{
      type: type,
      purpose: parse_purpose(purpose),
      coin_type: parse_coin_type(coin_type),
      account: account,
      change: change,
      address_index: address_index
    }
  end

  @doc """
  Turns a list of path values into a %DerivationPath{}

  ## Examples
    iex> ["m", 0x80000054, 0x80000000, 0x80000005]
    ...> |> BitcoinLib.Key.HD.DerivationPath.from_list
    %BitcoinLib.Key.HD.DerivationPath{
      type: "m",
      purpose: :bip84,
      coin_type: :bitcoin,
      account: 0x80000005
    }
  """
  @spec from_list(list()) :: %DerivationPath{}
  def from_list(values_list) do
    %PathValues{
      type: type,
      purpose: purpose,
      coin_type: coin_type,
      account: account,
      change: change,
      address_index: address_index
    } = PathValues.from_list(values_list)

    from_values(type, purpose, coin_type, account, change, address_index)
  end

  defp parse_purpose(purpose) when is_integer(purpose) do
    Purpose.parse(purpose - @hardened)
  end

  defp parse_coin_type(nil), do: nil

  defp parse_coin_type(coin_type) do
    CoinType.parse(coin_type - @hardened)
  end

  defp validate(derivation_path) do
    trimmed_path =
      derivation_path
      |> String.replace(" ", "")

    case Regex.match?(~r/^(m|M)((\/(\d+\'?)*){0,5})$/, trimmed_path) do
      true -> {:ok, trimmed_path}
      false -> {:error, "Invalid derivation path"}
    end
  end
end
