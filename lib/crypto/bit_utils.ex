defmodule BitcoinLib.Crypto.BitUtils do
  @moduledoc """
  Bitwise operations
  """

  @doc """
  Converts a binary into a list of integers with their bit sizes

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
  def split(binary, n) do
    split(binary, n, [])
  end

  defp split(binary, n, acc) when bit_size(binary) <= n do
    Enum.reverse([binary | acc])
  end

  defp split(binary, n, acc) do
    <<chunk::size(n), rest::bitstring>> = binary
    split(rest, n, [<<chunk::size(n)>> | acc])
  end
end
