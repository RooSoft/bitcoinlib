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
  @spec split(Binary.t(), Integer.t()) :: list(Binary.t())
  def split(binary, bit_size) do
    split(binary, bit_size, [])
  end

  defp split(binary, bit_size, acc) when bit_size(binary) <= bit_size do
    Enum.reverse([binary | acc])
  end

  defp split(binary, bit_size, acc) do
    <<chunk::size(bit_size), rest::bitstring>> = binary
    split(rest, bit_size, [<<chunk::size(bit_size)>> | acc])
  end
end
