defmodule BitcoinLib.Key.HD.ExtendedPublic.Address do
  alias BitcoinLib.Key.PublicKey
  alias BitcoinLib.Key.HD.ExtendedPublic.Address.{P2PKH, P2SH, Bech32}

  @spec from_public_key(%PublicKey{}, :p2pkh | :p2sh | :bech32, :mainnet | :testnet) ::
          binary()
  def from_public_key(%PublicKey{} = public_key, :p2pkh, :mainnet),
    do: P2PKH.from_public_key(public_key)

  def from_public_key(%PublicKey{} = public_key, :p2pkh, :testnet),
    do: P2PKH.from_public_key(public_key, :testnet)

  def from_public_key(%PublicKey{} = public_key, :p2sh, :mainnet),
    do: P2SH.from_public_key(public_key)

  def from_public_key(%PublicKey{} = public_key, :p2sh, :testnet),
    do: P2SH.from_public_key(public_key, :testnet)

  def from_public_key(%PublicKey{} = public_key, :bech32, :mainnet),
    do: Bech32.from_public_key(public_key)

  def from_public_key(%PublicKey{} = public_key, :bech32, :testnet),
    do: Bech32.from_public_key(public_key, :testnet)
end
