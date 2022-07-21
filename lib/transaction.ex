defmodule BitcoinLib.Transaction do
  @moduledoc """
  Based on https://learnmeabitcoin.com/technical/transaction-data#fields
  """
  defstruct [:input_count]

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Transaction

  def decode(encoded_transaction) do
    %{input_count: input_count} =
      %{remaining: encoded_transaction}
      |> extract_version
      |> extract_input_count

    %Transaction{input_count: input_count}
  end

  defp extract_version(%{remaining: <<version::32, remaining::bitstring>>} = map) do
    %{map | remaining: remaining}
    |> Map.put(:version, version)
  end

  defp extract_input_count(%{remaining: remaining} = map) do
    %BitcoinLib.Signing.Psbt.CompactInteger{value: input_count, remaining: remaining} =
      CompactInteger.extract_from(remaining)

    %{map | remaining: remaining}
    |> Map.put(:input_count, input_count)
  end
end
