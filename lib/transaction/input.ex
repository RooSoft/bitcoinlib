defmodule BitcoinLib.Transaction.Input do
  defstruct [:txid, :vout, :script_sig, :sequence]

  @moduledoc """
  Based on https://learnmeabitcoin.com/technical/input
  """

  @byte 8

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Transaction.Input
  alias BitcoinLib.Script
  alias BitcoinLib.Signing.Psbt.CompactInteger

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

  @doc """
  Encodes an input into a bitstring

  ## Examples

    iex> %BitcoinLib.Transaction.Input{
    ...>   sequence: 0xFFFFFFFF,
    ...>   txid: "5e2383defe7efcbdc9fdd6dba55da148b206617bbb49e6bb93fce7bfbb459d44",
    ...>   vout: 1
    ...> } |> BitcoinLib.Transaction.Input.encode()
    <<0x449d45bbbfe7fc93bbe649bb7b6106b248a15da5dbd6fdc9bdfc7efede83235e0100000000ffffffff::328>>
  """
  def encode(%Input{} = input) do
    little_endian_txid =
      Binary.from_hex(input.txid)
      |> :binary.decode_unsigned(:big)
      |> :binary.encode_unsigned(:little)

    {script_size, script} =
      input.script_sig
      |> format_script_sig()

    <<script_size::bitstring, script::bitstring>>

    <<little_endian_txid::bitstring-256, input.vout::little-32, script_size::bitstring,
      script::bitstring, input.sequence::little-32>>
  end

  defp format_script_sig(nil), do: {<<0::8>>, <<>>}
  defp format_script_sig(script_sig) when is_list(script_sig), do: script_sig |> Script.encode()

  defp format_script_sig(script_sig) when is_binary(script_sig) do
    script_sig_bit_size = byte_size(script_sig)

    {<<script_sig_bit_size::8>>, script_sig}
  end

  defp extract_script_sig(remaining) do
    %CompactInteger{value: script_sig_size, remaining: remaining} =
      CompactInteger.extract_from(remaining)

    script_sig_bit_size = script_sig_size * @byte

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
