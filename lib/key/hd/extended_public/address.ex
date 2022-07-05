defmodule BitcoinLib.Key.HD.ExtendedPublic.Address do
  alias BitcoinLib.Key.HD.ExtendedPublic
  alias BitcoinLib.Key.HD.ExtendedPublic.Address.P2SH

  @spec from_extended_public_key(%ExtendedPublic{}, :p2pkh | :p2sh) :: String.t()
  def from_extended_public_key(%ExtendedPublic{key: key}, :p2pkh) do
    key
    |> BitcoinLib.Key.PublicHash.from_public_key()
    |> BitcoinLib.Key.Address.from_public_key_hash(:p2pkh)
  end

  def from_extended_public_key(%ExtendedPublic{} = public_key, :p2sh) do
    public_key
    |> P2SH.from_extended_public_key()
  end
end
