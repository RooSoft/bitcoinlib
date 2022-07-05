defmodule BitcoinLib.Key.HD.ExtendedPublic.Address.P2PKH do
  alias BitcoinLib.Key.HD.ExtendedPublic

  def from_extended_public_key(%ExtendedPublic{key: key}) do
    key
    |> BitcoinLib.Key.PublicHash.from_public_key()
    |> BitcoinLib.Key.Address.from_public_key_hash(:p2pkh)
  end
end
