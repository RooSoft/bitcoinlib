defmodule BitcoinLib.Transaction.Output do
  defstruct [:value, :script_pub_key]

  @moduledoc """
  Based on https://learnmeabitcoin.com/technical/output
  """

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Transaction.Output

  def extract_from(<<value::little-64, remaining::bitstring>>) do
    {script_pub_key, remaining} = extract_script_pub_key(remaining)

    output =
      %Output{value: value, script_pub_key: Binary.to_hex(script_pub_key)}

    {output, remaining}
  end

  defp extract_script_pub_key(remaining) do
    %CompactInteger{value: script_pub_key_size, remaining: remaining} =
      CompactInteger.extract_from(remaining)

    <<script_pub_key::binary-size(script_pub_key_size), remaining::bitstring>> = remaining

    {script_pub_key, remaining}
  end
end
