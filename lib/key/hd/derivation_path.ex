defmodule BitcoinLib.Key.HD.DerivationPath do
  @moduledoc """
  Can parse derivation paths string format into a native format

  Inspired by https://learnmeabitcoin.com/technical/derivation-paths
  """

  # @mainnet_coin_type 0x80000000
  # @testnet_coin_type 0x80000001

  # @hardened_value 0x80000000

  @bip44_purpose 44
  @bip49_purpose 49
  @bip84_purpose 84

  @bip44_atom :bip44
  @bip49_atom :bip49
  @bip84_atom :bip84

  # @hardened_index_base 0x80000000

  @doc """
  Transforms a derivation path string into an elixir structure

  ## Examples
    iex> "m / 44' / 1' / 2' / 3 / 4"
    ...> |> BitcoinLib.Key.HD.DerivationPath.parse()
    { :ok,
      %{
        purpose: :bip44,
        coin_type: %{hardened?: true, value: 1},
        account: %{hardened?: true, value: 2},
        change: %{hardened?: false, value: 3},
        address_index: %{hardened?: false, value: 4}
      }
    }
  """
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

    case Regex.match?(~r/^m((\/(\d+\'?)*){5})$/, trimmed_path) do
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

      %{
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
        _ -> :invalid
      end
    )
  end

  defp add_status_code(
         %{
           purpose: purpose,
           coin_type: %{hardened?: _, value: _},
           account: %{hardened?: _, value: _},
           change: %{hardened?: _, value: _},
           address_index: %{hardened?: _, value: _}
         } = result
       ) do
    case purpose do
      :invalid -> {:error, "Invalid purpose"}
      _ -> {:ok, result}
    end
  end

  defp add_status_code(_result) do
    {:error, "Some parameters are missing"}
  end
end
