defmodule BitcoinLib.Signing.Psbt.CompactInteger do
  @moduledoc """
  based on https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer
  """

  @_16_bits 0xFD
  @_32_bits 0xFE
  @_64_bits 0xFF
  @byte 8

  def extract_from(<<@_16_bits::8, data::binary>>) do
    IO.puts("FD")
    <<length::16, data::binary>> = data

    data
    |> extract_size(length)
  end

  def extract_from(<<@_32_bits::8, data::binary>>) do
    IO.puts("FE")
    <<length::32, data::binary>> = data

    data
    |> extract_size(length)
  end

  def extract_from(<<@_64_bits::8, data::binary>>) do
    IO.puts("FF")
    <<length::64, data::binary>> = data

    data
    |> extract_size(length)
  end

  def extract_from(<<value::8, remaining::binary>>) do
    {value, remaining}
  end

  def extract_size(data, length) do
    case data do
      <<value::length*@byte>> -> {value, <<>>}
      <<value::length*@byte, remaining>> -> {value, remaining}
    end
  end
end
