defmodule BitcoinLib.Key.Address do
  @moduledoc """
  Bitcoin address management

  Inspired by https://learnmeabitcoin.com/technical/public-key-hash
  """

  alias BitcoinLib.Crypto

  @doc """
  Convert public key hash into a P2PKH Bitcoin address.

  Details can be found here: https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses

  ## Examples
    iex> 0x6ae201797de3fa7d1d95510f50c1a9c50ce4cc36
    ...> |> BitcoinLib.Key.Address.from_public_key_hash(:p2pkh)
    "1Ak9NVPmwCHEpsSWvM6cNRC7dsYniRmwMG"
  """
  @spec from_public_key_hash(integer(), :p2pkh | :p2sh, :mainnet | :testnet) :: String.t()
  def from_public_key_hash(public_key_hash, address_type \\ :p2sh, network \\ :mainnet) do
    public_key_hash
    |> Integer.to_string(16)
    |> prepend_prefix(address_type, network)
    |> append_checksum
    |> Binary.from_hex()
    |> Base58.encode()
  end

  defp prepend_prefix(public_key_hash, address_type, network) do
    get_prefix(address_type, network) <> public_key_hash
  end

  defp append_checksum(public_key_hash) do
    checksum =
      public_key_hash
      |> Crypto.checksum()

    public_key_hash <> checksum
  end

  defp get_prefix(:p2pkh, :mainnet), do: "00"
  defp get_prefix(:p2sh, :mainnet), do: "05"
  defp get_prefix(:p2pkh, :testnet), do: "6F"
  defp get_prefix(:p2sh, :testnet), do: "C4"
end
