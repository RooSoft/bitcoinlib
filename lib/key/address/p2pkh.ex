defmodule BitcoinLib.Key.Address.P2PKH do
  @moduledoc """
  Implementation of P2PKH addresses

  Sources:
  - https://learnmeabitcoin.com/technical/address#pay-to-pubkey-hash-p2pkh
  - https://en.bitcoinwiki.org/wiki/Pay-to-Pubkey_Hash
  """

  alias BitcoinLib.Key.{PublicKey, Address}
  alias BitcoinLib.Crypto

  @doc """
  Converts an extended public key into a P2PKH address starting by 1

  ## Examples
      iex> %BitcoinLib.Key.PublicKey{
      ...>  key: <<0x02D0DE0AAEAEFAD02B8BDC8A01A1B8B11C696BD3D66A2C5F10780D95B7DF42645C::264>>,
      ...>  chain_code: <<0::256>>
      ...> } |> BitcoinLib.Key.Address.P2PKH.from_public_key()
      "1LoVGDgRs9hTfTNJNuXKSpywcbdvwRXpmK"
  """
  @spec from_public_key(%PublicKey{}, :mainnet | :testnet) :: binary()
  def from_public_key(%PublicKey{} = public_key, network \\ :mainnet) do
    public_key
    |> PublicKey.hash()
    |> Address.from_public_key_hash(network)
  end

  @doc """
  Creates a P2PKH address, which is starting by 1, out of a script hash

  ## Examples
      iex> <<0xba27f99e007c7f605a8305e318c1abde3cd220ac::160>>
      ...> |> BitcoinLib.Key.Address.P2PKH.from_public_key_hash(:testnet)
      "mxVFsFW5N4mu1HPkxPttorvocvzeZ7KZyk"
  """
  @spec from_public_key_hash(<<_::160>>, :mainnet | :testnet) :: binary()
  def from_public_key_hash(<<_::160>> = public_key_hash, network \\ :mainnet) do
    public_key_hash
    |> prepend_version_bytes(network)
    |> append_checksum()
    |> base58_encode
  end

  defp prepend_version_bytes(data, network) do
    prefix = get_prefix(network)

    <<prefix::bitstring, data::bitstring>>
  end

  defp get_prefix(:mainnet), do: <<0::8>>
  defp get_prefix(:testnet), do: <<0x6F::8>>

  defp append_checksum(data) do
    checksum =
      data
      |> Crypto.checksum()

    data <> checksum
  end

  defp base58_encode(data) do
    Base58.encode(data)
  end
end
