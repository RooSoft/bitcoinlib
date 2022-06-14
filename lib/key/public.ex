defmodule BitcoinLib.Key.Public do
  @moduledoc """
  Bitcoin public key management module
  """

  @doc """
  Derives a public key from a private key in both uncompressed and compressed format

  Based on https://learnmeabitcoin.com/technical/public-key

  ## Examples
    iex> "0a8d286b11b98f6cb2585b627ff44d12059560acd430dcfa1260ef2bd9569373"
    ...> |> BitcoinLib.Key.Public.from_private_key
    {
      "040f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053002119e16b613619691f760eadd486315fc9e36491c7adb76998d1b903b3dd12",
      "020f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053"
    }
  """
  @spec from_private_key(String.t()) :: {String.t(), String.t()}
  def from_private_key(private_key) when is_binary(private_key) do
    bitstring_private_key =
      private_key
      |> String.upcase()
      |> Base.decode16!()

    {public_uncompressed, _private} =
      :crypto.generate_key(:ecdh, :secp256k1, bitstring_private_key)

    compressed = get_compressed(public_uncompressed)

    {
      Base.encode16(public_uncompressed, case: :lower),
      Base.encode16(compressed, case: :lower)
    }
  end

  def from_private_key(private_key) when is_integer(private_key) do
    private_key
    |> Integer.to_string(16)
    |> from_private_key()
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
