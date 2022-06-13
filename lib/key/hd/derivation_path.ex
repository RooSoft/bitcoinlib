defmodule BitcoinLib.Key.HD.DerivationPath do
  @moduledoc """
  Can parse derivation paths string format into a native format

  Inspired by https://learnmeabitcoin.com/technical/derivation-paths
  """

  # @mainnet_coin_type 0x80000000
  # @testnet_coin_type 0x80000001

  # @bip44_purpose 0x8000002C

  # @hardened_index_base 0x80000000

  @doc """
  Transforms a derivation path string into an elixir structure

  ## Examples
    iex> "m / 44' / 0' / 0' / 0 / 0"
    ...> |> BitcoinLib.Key.HD.DerivationPath.parse()
    { :ok,
      %{
        purpose: %{hardened?: true, value: 44},
        coin_type: %{hardened?: true, value: 0},
        account: %{hardened?: true, value: 0},
        change: %{hardened?: false, value: 0},
        address_index: %{hardened?: false, value: 0}
      }
    }
  """
  def parse(derivation_path) do
    derivation_path
    |> split_path
    |> extract_string_values
    |> parse_values
    |> assign_keys
    |> create_hash
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

  defp add_status_code(
         %{
           purpose: %{hardened?: _, value: _},
           coin_type: %{hardened?: _, value: _},
           account: %{hardened?: _, value: _},
           change: %{hardened?: _, value: _},
           address_index: %{hardened?: _, value: _}
         } = result
       ) do
    {:ok, result}
  end

  defp add_status_code(_) do
    {:error, "Some parameters are missing"}
  end
end
