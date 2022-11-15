defmodule BitcoinLib.Address.P2WSH do
  @moduledoc """
  Implementation of P2WSH addresses

  see https://bitcoincore.org/en/segwit_wallet_dev/#native-pay-to-witness-script-hash-p2wsh
  """

  require Logger

  alias BitcoinLib.Address.Bech32

  @doc """
  Creates a P2WSH address out of a key hash

  ## Examples
      iex> <<0x6ff04018aff3bd320c89e2e8c9d4274e6b0e780975cd364810239ecc7bd8138a::256>>
      ...> |> BitcoinLib.Address.P2WSH.from_script_hash()
      "bc1qdlcyqx907w7nyryfut5vn4p8fe4su7qfwhxnvjqsyw0vc77czw9q6d8zkl"
  """
  @spec from_script_hash(<<_::256>>, :mainnet | :testnet) :: binary()
  def from_script_hash(script_hash, network \\ :mainnet) do
    from_script_pub_key(<<0x0020::16, script_hash::bitstring-256>>, network)
  end

  @doc """
  Creates a P2WSH address out of a script pub key

  ## Examples
      iex> <<0x00206ff04018aff3bd320c89e2e8c9d4274e6b0e780975cd364810239ecc7bd8138a::272>>
      ...> |> BitcoinLib.Address.P2WSH.from_script_pub_key()
      "bc1qdlcyqx907w7nyryfut5vn4p8fe4su7qfwhxnvjqsyw0vc77czw9q6d8zkl"
  """
  @spec from_script_pub_key(<<_::272>>, :mainnet | :testnet) :: binary()
  def from_script_pub_key(
        <<0x0020::16, _script_hash::bitstring-256>> = script_pub_key,
        network \\ :mainnet
      ) do
    Bech32.from_script_pub_key(script_pub_key, network)
  end
end
