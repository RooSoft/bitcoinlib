defmodule BitcoinLib.Signing.Psbt.CompactInteger do
  @moduledoc """
  based on https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer
  """

  @_16_bits 0xFD
  @_32_bits 0xFE
  @_64_bits 0xFF
  @byte 8

  def extract_from(<<@_16_bits::8, data::binary>>) do
    <<length::16, data::binary>> = data

    data
    |> extract_size(length)
  end

  def extract_from(<<@_32_bits::8, data::binary>>) do
    <<length::32, data::binary>> = data

    data
    |> extract_size(length)
  end

  def extract_from(<<@_64_bits::8, data::binary>>) do
    <<length::64, data::binary>> = data

    data
    |> extract_size(length)
  end

  def extract_from(<<length::8, data::binary>>) do
    data
    |> extract_size(length)
  end

  def extract_size(data, length) do
    case data do
      <<number::length*@byte>> -> {number, <<>>}
      <<number::length*@byte, remaining>> -> {number, remaining}
    end
  end
end
