defmodule BitcoinLib.Signing.Psbt.CompactInteger do
  @moduledoc """
  Extracts a variable length integer from a binary

  based on https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer
  """

  defstruct [:value, :size, :remaining]

  alias BitcoinLib.Signing.Psbt.CompactInteger

  @_8_bits_code 0xFC
  @_16_bits_code 0xFD
  @_32_bits_code 0xFE
  @_64_bits_code 0xFF

  @max_8_bits_value @_8_bits_code
  @max_16_bits_value 0xFFFF
  @max_32_bits_value 0xFFFFFFFF
  @max_64_bits_value 0xFFFFFFFFFFFFFFFF

  @doc """
  Encodes an integer according to the spec linked to in the moduledoc
  """
  @spec encode(integer(), :big_endian | :little_endian) :: bitstring()
  def encode(value, endianness \\ :little_endian)

  def encode(value, _) when value <= @max_8_bits_value do
    <<value::8>>
  end

  def encode(value, :little_endian) when value <= @max_16_bits_value do
    <<@_16_bits_code::8, value::little-16>>
  end

  def encode(value, :little_endian) when value <= @max_32_bits_value do
    <<@_32_bits_code::8, value::little-32>>
  end

  def encode(value, :little_endian) when value <= @max_64_bits_value do
    <<@_64_bits_code::8, value::little-64>>
  end

  def encode(value, :big_endian) when value <= @max_16_bits_value do
    <<0xFD::8, value::16>>
  end

  def encode(value, :big_endian) when value <= @max_32_bits_value do
    <<0xFE::8, value::32>>
  end

  def encode(value, :big_endian) when value <= @max_64_bits_value do
    <<0xFF::8, value::64>>
  end

  @doc """
  Extracts a variable length integer from a bitstring according to the spec linked in the moduledoc,
  returns a tuple containing the integer with the remaining of the bitstring
  """
  @spec extract_from(bitstring(), :big_endian | :little_endian) :: %CompactInteger{}
  def extract_from(data, endianness \\ :little_endian)

  def extract_from(<<@_16_bits_code::8, data::bitstring>>, endianness) do
    data
    |> extract_size(16, endianness)
  end

  def extract_from(<<@_32_bits_code::8, data::bitstring>>, endianness) do
    data
    |> extract_size(32, endianness)
  end

  def extract_from(<<@_64_bits_code::8, data::bitstring>>, endianness) do
    data
    |> extract_size(64, endianness)
  end

  def extract_from(<<value::8, remaining::bitstring>>, _endianness) do
    %CompactInteger{value: value, size: 8, remaining: remaining}
  end

  defp extract_size(data, length, :big_endian) do
    case data do
      <<value::size(length)>> ->
        %CompactInteger{value: value, size: length, remaining: <<>>}

      <<value::size(length), remaining::bitstring>> ->
        %CompactInteger{value: value, size: length, remaining: remaining}
    end
  end

  defp extract_size(data, length, :little_endian) do
    case data do
      <<value::little-size(length)>> ->
        %CompactInteger{value: value, size: length, remaining: <<>>}

      <<value::little-size(length), remaining::bitstring>> ->
        %CompactInteger{value: value, size: length, remaining: remaining}
    end
  end
end
