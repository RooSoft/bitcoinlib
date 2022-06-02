defmodule BitcoinLib.Key.Address do
  alias BitcoinLib.Crypto

  @doc """
  Convert public key hash into a P2PKH Bitcoin address.

  Details can be found here: https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
  """
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
