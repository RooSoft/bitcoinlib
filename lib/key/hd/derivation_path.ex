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
    %{
      purpose: %{hardened?: true, value: 44},
      coin_type: %{hardened?: true, value: 0},
      account: %{hardened?: true, value: 0},
      change: %{hardened?: false, value: 0},
      address_index: %{hardened?: false, value: 0}
    }
  """
  def parse(derivation_path) do
    Regex.scan(~r/\/\s*(\d+\'?)/, derivation_path)
    |> Enum.map(fn [_, value] ->
      Regex.named_captures(~r/(?<value_string>\d+)(?<has_quote>\'?)/, value)
    end)
    |> Enum.map(fn %{"has_quote" => has_quote, "value_string" => value_string} ->
      {value, _} = Integer.parse(value_string)

      %{
        value: value,
        hardened?: has_quote == "'"
      }
    end)
    |> Enum.zip_with(
      ["purpose", "coin_type", "account", "change", "address_index"],
      fn value, title -> {String.to_atom(title), value} end
    )
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      acc
      |> Map.put(key, value)
    end)
  end
end
