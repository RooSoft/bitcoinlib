defmodule BitcoinLib.Transaction do
  @moduledoc """
  Based on https://learnmeabitcoin.com/technical/transaction-data#fields
  """
  defstruct [:input_count]

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Input}

  def decode(encoded_transaction) do
    %{input_count: input_count} =
      %{remaining: encoded_transaction}
      |> extract_version
      |> extract_input_count
      |> extract_inputs
      |> extract_output_count

    #    |> extract_outputs

    %Transaction{input_count: input_count}
  end

  defp extract_version(%{remaining: <<version::32, remaining::bitstring>>} = map) do
    %{map | remaining: remaining}
    |> Map.put(:version, version)
  end

  defp extract_input_count(%{remaining: remaining} = map) do
    %CompactInteger{value: input_count, remaining: remaining} =
      CompactInteger.extract_from(remaining, :big_endian)

    %{map | remaining: remaining}
    |> Map.put(:input_count, input_count)
  end

  defp extract_inputs(%{input_count: input_count, remaining: remaining} = map) do
    {inputs, remaining} =
      1..input_count
      |> Enum.reduce({[], remaining}, fn _nb, {inputs, remaining} ->
        {input, remaining} = Input.extract_from(remaining)

        {[input | inputs], remaining}
      end)

    %{map | remaining: remaining}
    |> Map.put(:inputs, inputs)
  end

  defp extract_output_count(%{remaining: remaining} = map) do
    %CompactInteger{value: output_count, remaining: remaining} =
      CompactInteger.extract_from(remaining, :big_endian)

    %{map | remaining: remaining}
    |> Map.put(:output_count, output_count)
  end

  # defp extract_outputs(%{output_count: output_count, remaininig: remaining} = map) do

  # end
end
