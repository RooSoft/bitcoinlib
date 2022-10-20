defmodule BitcoinLib.Key.PublicKey.Address do
  @moduledoc """
  Converts public keys into Bitcoin addresses of different formats
  """
  alias BitcoinLib.Key.PublicKey
  alias BitcoinLib.Key.Address.{P2PKH, P2SH, Bech32}

  @doc """
  Turns a public key into an address of the specified format

  ## Examples
    iex> %BitcoinLib.Key.PublicKey{
    ...>   key: <<0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC::264>>
    ...> }
    ...> |> BitcoinLib.Key.PublicKey.Address.from_public_key(:bech32, :mainnet)
    "bc1qa5gyew808tdta3wjh6qh3jvcglukjsnfg0qx4u"
  """
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
