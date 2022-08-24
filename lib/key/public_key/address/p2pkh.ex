defmodule BitcoinLib.Key.PublicKey.Address.P2PKH do
  @moduledoc """
  Implementation of P2PKH addresses

  Sources:
  - https://learnmeabitcoin.com/technical/address#pay-to-pubkey-hash-p2pkh
  - https://en.bitcoinwiki.org/wiki/Pay-to-Pubkey_Hash
  """

  alias BitcoinLib.Key.PublicKey

  @doc """
  Converts an extended public key into a P2PKH address starting by 1

  ## Examples
    iex> %BitcoinLib.Key.PublicKey{
    ...>  key: <<0x02D0DE0AAEAEFAD02B8BDC8A01A1B8B11C696BD3D66A2C5F10780D95B7DF42645C::264>>,
    ...>  chain_code: <<0::256>>
    ...> } |> BitcoinLib.Key.PublicKey.Address.P2PKH.from_public_key()
    "1LoVGDgRs9hTfTNJNuXKSpywcbdvwRXpmK"
  """
  def from_public_key(%PublicKey{} = public_key, network \\ :mainnet) do
    public_key
    |> BitcoinLib.Key.PublicHash.from_public_key()
    |> BitcoinLib.Key.Address.from_public_key_hash(:p2pkh, network)
  end
end
