defmodule BitcoinLib.Transaction.Input do
  defstruct [:txid, :vout, :script_sig, :sequence]

  @moduledoc """
  Based on https://learnmeabitcoin.com/technical/input
  """

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Transaction.Input

  def extract_from(<<txid::little-256, vout::little-32, remaining::binary>>) do
    {script_sig, remaining} = extract_script_sig(remaining)
    {sequence, remaining} = extract_sequence(remaining)

    {
      %Input{txid: txid, vout: vout, script_sig: script_sig, sequence: sequence},
      remaining
    }
  end

  defp extract_script_sig(remaining) do
    %CompactInteger{value: script_sig_size, remaining: remaining} =
      CompactInteger.extract_from(remaining)

    <<script_sig::size(script_sig_size), remaining::bitstring>> = remaining

    {script_sig, remaining}
  end

  defp extract_sequence(remaining) do
    <<sequence::little-32, remaining::bitstring>> = remaining

    {sequence, remaining}
  end
end
