defmodule BitcoinLib.Key.Public do
  @moduledoc """
  Public key operations.
  """

  @type t :: binary

  def from_private_key(private_key) do
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
