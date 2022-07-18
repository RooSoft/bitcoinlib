defmodule BitcoinLib.Signing.Psbt.CompactInteger do
  @moduledoc """
  based on https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer
  """

  @_16_bits_code 0xFD
  @_32_bits_code 0xFE
  @_64_bits_code 0xFF

  def extract_from(<<@_16_bits_code::8, data::binary>>) do
    data
    |> extract_size(16)
  end

  def extract_from(<<@_32_bits_code::8, data::binary>>) do
    data
    |> extract_size(32)
  end

  def extract_from(<<@_64_bits_code::8, data::binary>>) do
    data
    |> extract_size(64)
  end

  def extract_from(<<value::8, remaining::binary>>) do
    {value, remaining}
  end

  def extract_size(data, length) do
    case data do
      <<value::size(length)>> -> {value, <<>>}
      <<value::size(length), remaining::binary>> -> {value, remaining}
    end
  end
end
