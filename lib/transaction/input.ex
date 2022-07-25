defmodule BitcoinLib.Transaction.Input do
  defstruct [:txid, :vout, :script_sig, :sequence]

  @moduledoc """
  Based on https://learnmeabitcoin.com/technical/input
  """

  @input_termination 0xFFFFFFFF

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Transaction.Input

  def extract_from(<<txid::little-256, vout::little-32, remaining::binary>>) do
    {script_sig, remaining} = extract_script_sig(remaining)
    remaining = terminate(remaining)

    {
      %Input{txid: txid, vout: vout, script_sig: script_sig},
      remaining
    }
  end

  defp extract_script_sig(remaining) do
    %CompactInteger{value: script_sig_size, remaining: remaining} =
      CompactInteger.extract_from(remaining)

    <<script_sig::size(script_sig_size), remaining::bitstring>> = remaining

    {script_sig, remaining}
  end

  defp terminate(remaining) do
    <<@input_termination::32, remaining::bitstring>> = remaining

    remaining
  end
end
