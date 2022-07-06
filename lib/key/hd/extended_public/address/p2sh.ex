defmodule BitcoinLib.Key.HD.ExtendedPublic.Address.P2SH do
  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.ExtendedPublic

  def from_extended_public_key(%ExtendedPublic{key: key}) do
    key
    |> Binary.from_integer()
    |> hash160
    |> create_redeem_script
    |> hash160
    |> add_version_bytes
    |> append_checksum
    |> base58_encode
  end

  defp hash160(value) do
    value
    |> Crypto.hash160_bitstring()
  end

  defp create_redeem_script(public_key_hash) do
    <<0x14::size(16), public_key_hash::bitstring>>
  end

  defp add_version_bytes(redeem_script) do
    <<5::size(8), redeem_script::bitstring>>
  end

  defp base58_encode(value) do
    value
    |> Base58.encode()
  end

  defp append_checksum(public_key_hash) do
    hex_public_key_hash =
      public_key_hash
      |> Binary.to_hex()

    checksum =
      hex_public_key_hash
      |> Crypto.checksum()

    (hex_public_key_hash <> checksum)
    |> Binary.from_hex()
  end
end
