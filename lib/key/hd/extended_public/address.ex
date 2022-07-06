defmodule BitcoinLib.Key.HD.ExtendedPublic.Address do
  alias BitcoinLib.Key.HD.ExtendedPublic
  alias BitcoinLib.Key.HD.ExtendedPublic.Address.{P2PKH, P2SH, Bech32}

  @spec from_extended_public_key(%ExtendedPublic{}, :p2pkh | :p2sh) :: String.t()
  def from_extended_public_key(%ExtendedPublic{} = public_key, :p2pkh) do
    public_key
    |> P2PKH.from_extended_public_key()
  end

  def from_extended_public_key(%ExtendedPublic{} = public_key, :p2sh) do
    public_key
    |> P2SH.from_extended_public_key()
  end

  def from_extended_public_key(%ExtendedPublic{} = public_key, :bech32) do
    public_key
    |> Bech32.from_extended_public_key()
  end
end
