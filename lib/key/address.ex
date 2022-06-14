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
  @spec from_public_key_hash(Integer.t(), :p2pkh | :p2sh) :: String.t()
  def from_public_key_hash(public_key_hash, address_type \\ :p2sh) do
    public_key_hash
    |> Integer.to_string(16)
    |> prepend_prefix(address_type)
    |> append_checksum
    |> Binary.from_hex()
    |> Base58.encode()
  end

  defp prepend_prefix(public_key_hash, address_type) do
    get_prefix(address_type) <> public_key_hash
  end

  defp append_checksum(public_key_hash) do
    checksum =
      public_key_hash
      |> Crypto.checksum()

    public_key_hash <> checksum
  end

  defp get_prefix(address_type) do
    case address_type do
      :p2pkh -> "00"
      :p2sh -> "05"
    end
  end
end
