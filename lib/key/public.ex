defmodule BitcoinLib.Key.Public do
  @moduledoc """
  Bitcoin public key management module
  """

  alias BitcoinLib.Crypto

  @doc """
  Derives a public key from a private key in both uncompressed and compressed format

  Based on https://learnmeabitcoin.com/technical/public-key

  ## Examples
    iex> 0x0a8d286b11b98f6cb2585b627ff44d12059560acd430dcfa1260ef2bd9569373
    ...> |> BitcoinLib.Key.Public.from_private_key
    {
      0x040f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053002119e16b613619691f760eadd486315fc9e36491c7adb76998d1b903b3dd12,
      0x020f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053
    }
  """
  @spec from_private_key(integer()) :: {integer(), integer()}
  def from_private_key(private_key) do
    bitstring_private_key =
      private_key
      |> Binary.from_integer()

    public_uncompressed = Crypto.secp256k1_bitstring(bitstring_private_key)

    compressed = get_compressed(public_uncompressed)

    {
      public_uncompressed |> Binary.to_integer(),
      compressed |> Binary.to_integer()
    }
  end

  defp get_compressed(public_uncompressed) do
    first_char =
      public_uncompressed
      |> get_first_char

    compressed_body =
      public_uncompressed
      |> Binary.part(1, 32)

    first_char <> compressed_body
  end

  defp get_first_char(public_uncompressed) do
    reminder =
      public_uncompressed
      |> Binary.last()
      |> rem(2)

    case reminder do
      0 -> <<2>>
      1 -> <<3>>
    end
  end
end
