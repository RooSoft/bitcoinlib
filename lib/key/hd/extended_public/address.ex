defmodule BitcoinLib.Key.HD.ExtendedPublic.Address do
  alias BitcoinLib.Key.HD.ExtendedPublic
  alias BitcoinLib.Key.HD.ExtendedPublic.Address.{P2PKH, P2SH, Bech32}

  @spec from_extended_public_key(%ExtendedPublic{}, :p2pkh | :p2sh | :bech32, :mainnet | :testnet) ::
          binary()
  def from_extended_public_key(%ExtendedPublic{} = public_key, :p2pkh, :mainnet),
    do: P2PKH.from_extended_public_key(public_key)

  def from_extended_public_key(%ExtendedPublic{} = public_key, :p2pkh, :testnet),
    do: P2PKH.from_extended_public_key(public_key, :testnet)

  def from_extended_public_key(%ExtendedPublic{} = public_key, :p2sh, :mainnet),
    do: P2SH.from_extended_public_key(public_key)

  def from_extended_public_key(%ExtendedPublic{} = public_key, :p2sh, :testnet),
    do: P2SH.from_extended_public_key(public_key, :testnet)

  def from_extended_public_key(%ExtendedPublic{} = public_key, :bech32, :mainnet),
    do: Bech32.from_extended_public_key(public_key)

  def from_extended_public_key(%ExtendedPublic{} = public_key, :bech32, :testnet),
    do: Bech32.from_extended_public_key(public_key, :testnet)
end
