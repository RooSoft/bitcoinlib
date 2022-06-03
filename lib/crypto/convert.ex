defmodule BitcoinLib.Crypto.Convert do
  @moduledoc """
  Cryptography helper functions
  """

  @doc """
  Converts an integer, most probably a private key, into a 0 padded binary of a fix length

  ## Examples
    iex> 0x0A8D286B11B98F6CB2585B627FF44D12059560ACD430DCFA1260EF2BD9569373
    ...> |> BitcoinLib.Crypto.Convert.integer_to_binary()
    << 10, 141, 40, 107, 17, 185, 143, 108, 178, 88,
       91, 98, 127, 244, 77, 18, 5, 149, 96, 172, 212,
       48, 220, 250, 18, 96, 239, 43, 217, 86, 147, 115>>
  """
  def integer_to_binary(value, bytes_length \\ 32) do
    value
    |> Binary.from_integer()
    |> Binary.pad_leading(bytes_length)
  end
end
