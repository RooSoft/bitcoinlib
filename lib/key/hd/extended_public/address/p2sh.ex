defmodule BitcoinLib.Key.HD.ExtendedPublic.Address.P2SH do
  @moduledoc """
  Implementation of P2SH-P2WPKH addresses

  BIP13: Address Format for pay-to-script-hash  https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
  BIP16: Pay to Script Hash                     https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki


  Source: https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
  """

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.ExtendedPublic

  @doc """
  Creates a P2SH-P2WPKH address, which is starting by 3, out of an Extended Public Key

  ## Examples
    iex> %BitcoinLib.Key.HD.ExtendedPublic{
    ...>  key: 0x02D0DE0AAEAEFAD02B8BDC8A01A1B8B11C696BD3D66A2C5F10780D95B7DF42645C,
    ...>  chain_code: 0
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.Address.P2SH.from_extended_public_key()
    "3D9iyFHi1Zs9KoyynUfrL82rGhJfYTfSG4"
  """
  def from_extended_public_key(%ExtendedPublic{key: key}) do
    key
    |> to_binary
    |> hash160
    |> create_redeem_script
    |> hash160
    |> prepend_version_bytes
    |> append_checksum
    |> base58_encode
  end

  defp to_binary(key) do
    key
    |> Binary.from_integer()
  end

  defp hash160(value) do
    value
    |> Crypto.hash160_bitstring()
  end

  defp create_redeem_script(public_key_hash) do
    <<0x14::size(16), public_key_hash::bitstring>>
  end

  defp prepend_version_bytes(redeem_script) do
    <<5::size(8), redeem_script::bitstring>>
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

  defp base58_encode(value) do
    value
    |> Base58.encode()
  end
end
