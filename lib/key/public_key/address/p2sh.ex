defmodule BitcoinLib.Key.PublicKey.Address.P2SH do
  @moduledoc """
  Implementation of P2SH-P2WPKH addresses

  BIP13: Address Format for pay-to-script-hash  https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
  BIP16: Pay to Script Hash                     https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki


  Source: https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
  """

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.PublicKey

  @doc """
  Creates a P2SH-P2WPKH address, which is starting by 3, out of an Extended Public Key

  ## Examples
    iex> %BitcoinLib.Key.PublicKey{
    ...>  key: <<0x02D0DE0AAEAEFAD02B8BDC8A01A1B8B11C696BD3D66A2C5F10780D95B7DF42645C::264>>,
    ...>  chain_code: <<0::256>>
    ...> }
    ...> |> BitcoinLib.Key.PublicKey.Address.P2SH.from_public_key()
    "3D9iyFHi1Zs9KoyynUfrL82rGhJfYTfSG4"
  """
  @spec from_public_key(%PublicKey{}, :mainnet | :testnet) :: binary()
  def from_public_key(%PublicKey{key: key}, network \\ :mainnet) do
    key
    |> hash160
    |> create_redeem_script
    |> hash160
    |> prepend_version_bytes(network)
    |> append_checksum
    |> base58_encode
  end

  defp hash160(value) do
    value
    |> Crypto.hash160()
  end

  defp create_redeem_script(public_key_hash) do
    <<0x14::size(16), public_key_hash::bitstring>>
  end

  defp prepend_version_bytes(redeem_script, :mainnet) do
    <<5::size(8), redeem_script::bitstring>>
  end

  defp prepend_version_bytes(redeem_script, :testnet) do
    <<0xC4::size(8), redeem_script::bitstring>>
  end

  defp append_checksum(public_key_hash) do
    checksum =
      public_key_hash
      |> Crypto.checksum()

    <<public_key_hash::bitstring, checksum::bitstring>>
  end

  defp base58_encode(value) do
    value
    |> Base58.encode()
  end
end
