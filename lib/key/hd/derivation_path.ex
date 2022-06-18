defmodule BitcoinLib.Key.HD.DerivationPath do
  @moduledoc """
  Can parse derivation paths string format into a native format

  m / purpose' / coin_type' / account' / change / address_index

  Inspired by

    https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
    https://learnmeabitcoin.com/technical/derivation-paths
  """

  defstruct [:purpose, :coin_type, :account, :change, :address_index]

  alias BitcoinLib.Key.HD.DerivationPath.Level

  # https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#purpose
  @bip44_purpose 44
  @bip44_atom :bip44

  # https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki#public-key-derivation
  @bip49_purpose 49
  @bip49_atom :bip49

  # https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#public-key-derivation
  @bip84_purpose 84
  @bip84_atom :bip84

  # https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#registered-coin-types
  @bitcoin_coin_type_value 0
  @bitcoin_testnet_coin_type_value 1

  # https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#change
  @receiving_chain_value 0
  @receiving_chain_atom :receiving_chain
  @change_chain_value 1
  @change_chain_atom :change_chain

  @bitcoin_atom :bitcoin
  @bitcoin_testnet_atom :bitcoin_testnet

  @invalid_atom :invalid

  @doc """
  Transforms a derivation path string into an elixir structure

  ## Examples
    iex> "m / 44' / 1' / 2' / 1 / 4"
    ...> |> BitcoinLib.Key.HD.DerivationPath.parse()
    { :ok,
      %{
        purpose: :bip44,
        coin_type: :bitcoin_testnet,
        account: %BitcoinLib.Key.HD.DerivationPath.Level{hardened?: true, value: 2},
        change: :change_chain,
        address_index: %BitcoinLib.Key.HD.DerivationPath.Level{hardened?: false, value: 4}
      }
    }
  """
  @spec parse(String.t()) ::
          {:ok,
           %BitcoinLib.Key.HD.DerivationPath{
             purpose: Atom.t(),
             coin_type: Atom.t(),
             account: %Level{},
             change: Atom.t(),
             address_index: %Level{}
           }}
  def parse(derivation_path) do
    derivation_path
    |> validate
    |> maybe_parse_valid_derivation_path()
  end

  defp validate(derivation_path) do
    trimmed_path =
      derivation_path
      |> String.replace(" ", "")
      |> String.downcase()

    case Regex.match?(~r/^m((\/(\d+\'?)*){0,5})$/, trimmed_path) do
      true -> {:ok, derivation_path}
      false -> {:error, "Invalid derivation path"}
    end
  end

  defp maybe_parse_valid_derivation_path({:error, _}) do
    {:error, "Invalid derivation path"}
  end

  defp maybe_parse_valid_derivation_path({:ok, derivation_path}) do
    derivation_path
    |> split_path
    |> extract_string_values
    |> parse_values
    |> assign_keys
    |> create_hash
    |> parse_purpose
    |> parse_coin_type
    |> parse_change
    |> add_status_code
  end

  defp split_path(derivation_path) do
    Regex.scan(~r/\/\s*(\d+\'?)/, derivation_path)
  end

  defp extract_string_values(split_path) do
    split_path
    |> Enum.map(fn [_, value] ->
      Regex.named_captures(~r/(?<value_string>\d+)(?<has_quote>\'?)/, value)
    end)
  end

  defp parse_values(string_values) do
    string_values
    |> Enum.map(fn %{"has_quote" => has_quote, "value_string" => value_string} ->
      {value, _} = Integer.parse(value_string)

      %Level{
        value: value,
        hardened?: has_quote == "'"
      }
    end)
  end

  defp assign_keys(parsed_values) do
    parsed_values
    |> Enum.zip_with(
      ["purpose", "coin_type", "account", "change", "address_index"],
      fn value, title -> {String.to_atom(title), value} end
    )
  end

  defp create_hash(keys_and_values) do
    keys_and_values
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      acc
      |> Map.put(key, value)
    end)
  end

  defp parse_purpose(%{purpose: %{hardened?: true, value: value}} = hash) do
    hash
    |> Map.put(
      :purpose,
      case value do
        @bip44_purpose -> @bip44_atom
        @bip49_purpose -> @bip49_atom
        @bip84_purpose -> @bip84_atom
        _ -> @invalid_atom
      end
    )
  end

  defp parse_coin_type(%{coin_type: %{hardened?: true, value: value}} = hash) do
    hash
    |> Map.put(
      :coin_type,
      case value do
        @bitcoin_coin_type_value -> @bitcoin_atom
        @bitcoin_testnet_coin_type_value -> @bitcoin_testnet_atom
        _ -> @invalid_atom
      end
    )
  end

  defp parse_change(%{change: %{hardened?: false, value: value}} = hash) do
    hash
    |> Map.put(
      :change,
      case value do
        @receiving_chain_value -> @receiving_chain_atom
        @change_chain_value -> @change_chain_atom
        _ -> @invalid_atom
      end
    )
  end

  defp add_status_code(%{purpose: @invalid_atom}) do
    {:error, "Invalid purpose"}
  end

  defp add_status_code(%{coin_type: @invalid_atom}) do
    {:error, "Invalid coin type"}
  end

  defp add_status_code(%{change: @invalid_atom}) do
    {:error, "Invalid change chain"}
  end

  defp add_status_code(result) do
    {:ok, result}
  end
end
