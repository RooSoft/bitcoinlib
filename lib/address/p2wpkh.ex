defmodule BitcoinLib.Address.P2WPKH do
  @moduledoc """
  Implementation of P2WPKH addresses

  see https://bitcoincore.org/en/segwit_wallet_dev/#native-pay-to-witness-public-key-hash-p2wpkh
  """

  require Logger

  alias BitcoinLib.Address.Bech32

  @doc """
  Creates a P2WPKH address out of a key hash

  ## Examples
      iex> <<0x13BFFF2D6DD02B8837F156C6F9FE0EA7363DF795::160>>
      ...> |> BitcoinLib.Address.P2WPKH.from_key_hash()
      "bc1qzwll7ttd6q4csdl32mr0nlsw5umrmau4es49qe"
  """
  @spec from_key_hash(<<_::160>>, :mainnet | :testnet) :: binary()
  def from_key_hash(key_hash, network \\ :mainnet) do
    from_script_pub_key(<<0x0014::16, key_hash::bitstring-160>>, network)
  end

  @doc """
  Creates a P2WPKH address out of a script pub key

  ## Examples
      iex> <<0x001413BFFF2D6DD02B8837F156C6F9FE0EA7363DF795::176>>
      ...> |> BitcoinLib.Address.P2WPKH.from_script_pub_key()
      "bc1qzwll7ttd6q4csdl32mr0nlsw5umrmau4es49qe"
  """
  @spec from_script_pub_key(<<_::176>>, :mainnet | :testnet) :: binary()
  def from_script_pub_key(
        <<0x0014::16, _script_hash::bitstring-160>> = script_pub_key,
        network \\ :mainnet
      ) do
    Bech32.from_script_pub_key(script_pub_key, network)
  end
end
