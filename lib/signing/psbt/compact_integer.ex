defmodule BitcoinLib.Signing.Psbt.CompactInteger do
  @moduledoc """
  Extracts a variable length integer from a binary

  based on https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer
  """

  defstruct [:value, :size, :remaining]

  alias BitcoinLib.Signing.Psbt.CompactInteger

  @_16_bits_code 0xFD
  @_32_bits_code 0xFE
  @_64_bits_code 0xFF

  @doc """
  Extracts a variable length integer from a bitstring according to the spec linked in the moduledoc,
  returns a tuple containing the integer with the remaining of the bitstring
  """
  @spec extract_from(bitstring(), :big_endian | :little_endian) :: {integer(), bitstring()}
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
