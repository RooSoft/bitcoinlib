defmodule BitcoinLib.Transaction.Output do
  defstruct [:value, :script_pub_key]

  @moduledoc """
  Based on https://learnmeabitcoin.com/technical/output
  """

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Transaction.Output

  @byte 8

  def extract_from(<<value::little-64, remaining::bitstring>>) do
    case extract_script_pub_key(remaining) do
      {:ok, script_pub_key, remaining} ->
        output = %Output{value: value, script_pub_key: script_pub_key}
        {output, remaining}

      {:error, message} ->
        {%{error: message}, remaining}
    end
  end

  defp extract_script_pub_key(remaining) do
    %CompactInteger{value: script_pub_key_size, remaining: remaining} =
      CompactInteger.extract_from(remaining)

    case script_pub_key_size <= byte_size(remaining) do
      true ->
        script_pub_key_bit_size = script_pub_key_size * @byte
        <<script_pub_key::bitstring-size(script_pub_key_bit_size), remaining::bitstring>> =
          remaining

        {:ok, script_pub_key, remaining}

      false ->
        {:error, "badly formatted script pub key"}
    end
  end
end
