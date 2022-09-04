defmodule BitcoinLib.Key.PublicKeyHash do
  @moduledoc """
  Bitcoin Public Key Hash module
  """

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.{PublicKey, Address}

  @doc """
  Extract a public key hash from a bitcoin public key

  Inspired by https://learnmeabitcoin.com/technical/public-key-hash

  ## Examples
    iex> %BitcoinLib.Key.PublicKey{
    ...>   key: <<0x02b4632d08485ff1df2db55b9dafd23347d1c47a457072a1e87be26896549a8737::264>>
    ...> }
    ...> |> BitcoinLib.Key.PublicKeyHash.from_public_key()
    <<0x93ce48570b55c42c2af816aeaba06cfee1224fae::160>>
  """
  @spec from_public_key(%PublicKey{}) :: bitstring()
  def from_public_key(%PublicKey{key: key}) do
    key
    |> Crypto.hash160()
  end

  @doc """
  Extracts the public key hash from an address, and make sure the checkum is ok

  ## Examples
    iex> address = "mwYKDe7uJcgqyVHJAPURddeZvM5zBVQj5L"
    ...> BitcoinLib.Key.PublicKeyHash.from_address(address)
    {:ok, <<0xafc3e518577316386188af748a816cd14ce333f2::160>>, :p2pkh}
  """
  @spec from_address(binary()) :: {:ok, bitstring(), atom()} | {:error, binary()}
  def from_address(address) do
    address
    |> Address.to_public_key_hash()
  end
end
