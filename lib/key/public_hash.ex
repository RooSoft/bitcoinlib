defmodule BitcoinLib.Key.PublicHash do
  alias BitcoinLib.Crypto

  def from_public_key(public_key) do
    public_key
    |> Binary.from_hex()
    |> Crypto.sha256_bitstring()
    |> Crypto.ripemd160_bitstring()
    |> Binary.to_hex()
  end
end
