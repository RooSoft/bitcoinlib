defmodule BitcoinLib.Signing.Psbt.CompactInteger do
  @moduledoc """
  Extracts a variable length integer from a binary

  based on https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer
  """

  @_16_bits_code 0xFD
  @_32_bits_code 0xFE
  @_64_bits_code 0xFF

  @doc """
  Extracts a variable length integer from a binary according to the spec linked in the moduledoc,
  returns a tuple containing the integer with the remaining of the binary
  """
  @spec extract_from(binary()) :: {integer(), binary()}
  def extract_from(<<@_16_bits_code::8, data::binary>>) do
    data
    |> extract_size(16)
  end

  @spec extract_from(binary()) :: {integer(), binary()}
  def extract_from(<<@_32_bits_code::8, data::binary>>) do
    data
    |> extract_size(32)
  end

  @spec extract_from(binary()) :: {integer(), binary()}
  def extract_from(<<@_64_bits_code::8, data::binary>>) do
    data
    |> extract_size(64)
  end

  @spec extract_from(binary()) :: {integer(), binary()}
  def extract_from(<<value::8, remaining::binary>>) do
    {value, remaining}
  end

  defp extract_size(data, length) do
    case data do
      <<value::size(length)>> -> {value, <<>>}
      <<value::size(length), remaining::binary>> -> {value, remaining}
    end
  end
end
