defmodule BitcoinLib.Crypto.BitUtils do
  @moduledoc """
  Bitwise operations
  """

  @doc """
  Converts a binary into a list of smaller binaries according to the bit size specification

  ## Examples
    iex> 0x6C7AB2F961A
    ...> |> Binary.from_integer()
    ...> |> BitcoinLib.Crypto.BitUtils.split(11)
    [
      <<6, 6::size(3)>>,
      <<61, 2::size(3)>>,
      <<203, 7::size(3)>>,
      <<44, 1::size(3)>>,
      <<10::size(4)>>
    ]
  """
  @spec split(binary(), integer()) :: list(binary())
  def split(binary, bit_size) do
    split(binary, bit_size, [])
  end

  @doc """
  Regroups a list of binaries into a single one

  ## Examples
    iex> [<<6, 6::size(3)>>, <<61, 2::size(3)>>, <<203, 7::size(3)>>, <<44, 1::size(3)>>, <<10::size(4)>>]
    ...> |> BitcoinLib.Crypto.BitUtils.combine
    <<6, 199, 171, 47, 150, 26>>
  """
  @spec combine(list(binary())) :: binary()
  def combine(binary_list) do
    binary_list
    |> Enum.reduce(<<>>, fn binary, acc ->
      <<acc::bitstring, binary::bitstring>>
    end)
  end

  defp split(binary, bit_size, acc) when bit_size(binary) <= bit_size do
    Enum.reverse([binary | acc])
  end

  defp split(binary, bit_size, acc) do
    <<chunk::size(bit_size), rest::bitstring>> = binary
    split(rest, bit_size, [<<chunk::size(bit_size)>> | acc])
  end
end
