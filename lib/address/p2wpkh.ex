defmodule BitcoinLib.Address.P2WPKH do
  @moduledoc """
  Implementation of P2WPKH addresses

  see https://bitcoincore.org/en/segwit_wallet_dev/#native-pay-to-witness-public-key-hash-p2wpkh
  """

  require Logger

  alias BitcoinLib.Address.Bech32

  def from_key_hash(key_hash, network \\ :mainnet) do
    from_script_pub_key(<<0x0014::16, key_hash::bitstring-160>>, network)
  end

  def from_script_pub_key(
        <<0x0014::16, _script_hash::bitstring-160>> = script_pub_key,
        network \\ :mainnet
      ) do
    Bech32.from_script_pub_key(script_pub_key, network)
  end
end
