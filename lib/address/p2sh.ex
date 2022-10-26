defmodule BitcoinLib.Address.P2SH do
  @moduledoc """
  Implementation of P2SH-P2WPKH addresses

  BIP13: Address Format for pay-to-script-hash  https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
  BIP16: Pay to Script Hash                     https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki


  Source: https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
  """

  require Logger

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.PublicKey

  @doc """
  Creates a P2SH-P2WPKH address, which is starting by 3, out of an Extended Public Key

  ## Examples
      iex> %BitcoinLib.Key.PublicKey{
      ...>  key: <<0x02D0DE0AAEAEFAD02B8BDC8A01A1B8B11C696BD3D66A2C5F10780D95B7DF42645C::264>>,
      ...>  chain_code: <<0::256>>
      ...> }
      ...> |> BitcoinLib.Address.P2SH.from_public_key()
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

  @doc """
  Creates a P2SH-P2WPKH address, which is starting by 3, out of a script hash

  ## Examples
      iex> <<0x11c371a2b2d22c7b8b1b51d9fde0e44a9dfdc7bb::160>>
      ...> |> BitcoinLib.Address.P2SH.from_script_hash(:testnet)
      "2Mts9cDyaoGfxPseMzxab2bAKHLW4o4SzAK"
  """
  @spec from_script_hash(bitstring(), :mainnet | :testnet) :: binary()
  def from_script_hash(script_hash, network \\ :mainnet) do
    script_hash
    |> prepend_version_bytes(network)
    |> append_checksum()
    |> base58_encode
  end

  @doc """
  Applies the address's checksum to make sure it's valid

  ## Examples
      iex> "2N4GxhpXrgdWJf5CaEoGWkoWCsW8NhygsKg"
      ...> |> BitcoinLib.Address.P2SH.valid?()
      true
  """
  @spec valid?(binary()) :: boolean()

  def valid?("2" <> _ = address) do
    address
    |> base58_decode
    |> validate_checksum()
  end

  def valid?("3" <> _ = address) do
    address
    |> base58_decode
    |> validate_checksum()
  end

  def valid?(address) do
    {:error, "#{address} is not a valid P2SH address"}
  end

  defp hash160(value) do
    value
    |> Crypto.hash160()
  end

  defp create_redeem_script(public_key_hash) do
    <<0x14::size(16), public_key_hash::bitstring>>
  end

  defp prepend_version_bytes(redeem_script, :mainnet) do
    <<5::8, redeem_script::bitstring>>
  end

  defp prepend_version_bytes(redeem_script, :testnet) do
    <<0xC4::8, redeem_script::bitstring>>
  end

  defp append_checksum(public_key_hash) do
    checksum =
      public_key_hash
      |> Crypto.checksum()

    <<public_key_hash::bitstring, checksum::bitstring>>
  end

  defp validate_checksum(<<data::bitstring-168, address_checksum::bitstring-32>>) do
    Crypto.checksum(data) == address_checksum
  end

  defp base58_encode(value) do
    value
    |> Base58.encode()
  end

  defp base58_decode(value) do
    value
    |> Base58.decode()
  end
end
