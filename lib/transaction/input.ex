defmodule BitcoinLib.Transaction.Input do
  defstruct [:txid, :vout, :script_sig, :sequence]

  @moduledoc """
  Based on https://learnmeabitcoin.com/technical/input
  """

  @bits 8

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Transaction.Input
  alias BitcoinLib.Script

  def extract_from(<<txid::little-256, vout::little-32, remaining::bitstring>>) do
    {script_sig, remaining} = extract_script_sig(remaining)
    {sequence, remaining} = extract_sequence(remaining)

    {
      %Input{
        txid: Integer.to_string(txid, 16) |> String.downcase(),
        vout: vout,
        script_sig: script_sig,
        sequence: sequence
      },
      remaining
    }
  end

  defp extract_script_sig(remaining) do
    %CompactInteger{value: script_sig_size, remaining: remaining} =
      CompactInteger.extract_from(remaining)

    script_sig_bit_size = script_sig_size * @bits

    <<script_sig::bitstring-size(script_sig_bit_size), remaining::bitstring>> = remaining

    script_sig =
      script_sig
      |> Script.parse()

    {script_sig, remaining}
  end

  defp extract_sequence(remaining) do
    <<sequence::little-32, remaining::bitstring>> = remaining

    {sequence, remaining}
  end
end
