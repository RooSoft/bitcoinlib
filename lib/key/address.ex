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
    iex> "6ae201797de3fa7d1d95510f50c1a9c50ce4cc36"
    ...> |> BitcoinLib.Key.Address.from_public_key_hash()
    "1Ak9NVPmwCHEpsSWvM6cNRC7dsYniRmwMG"
  """
  @spec from_public_key_hash(String.t()) :: String.t()
  def from_public_key_hash(public_key_hash) do
    public_key_hash
    |> prepend_prefix
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

  defp prepend_prefix(public_key_hash) do
    "00" <> public_key_hash
  end
end
