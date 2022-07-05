defmodule BitcoinLib.Key.HD.ExtendedPublic.Address.P2SH do
  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.ExtendedPublic

  def from_extended_public_key(%ExtendedPublic{key: key}) do
    key
    |> Binary.from_integer()
    |> Crypto.hash160_bitstring()
    |> create_redeem_script
    |> Crypto.hash160_bitstring()
    |> add_version_bytes
    |> Binary.to_hex()
    |> base58_encode()
  end

  defp create_redeem_script(public_key_hash) do
    <<0x14::size(16), public_key_hash::bitstring>>
  end

  defp add_version_bytes(hash) do
    <<5::size(8), hash::bitstring>>
  end

  defp base58_encode(value) do
    value
    |> append_checksum
    |> Binary.from_hex()
    |> Base58.encode()
  end

  defp append_checksum(public_key_hash) do
    checksum =
      public_key_hash
      |> Crypto.checksum()

    public_key_hash <> checksum
  end
end
