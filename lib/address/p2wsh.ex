defmodule BitcoinLib.Address.P2WSH do
  @moduledoc """
  Implementation of P2WSH addresses

  see https://bitcoincore.org/en/segwit_wallet_dev/#native-pay-to-witness-script-hash-p2wsh
  """

  require Logger

  alias BitcoinLib.Address.Bech32

  def from_script_hash(script_hash, network \\ :mainnet) do
    from_script_pub_key(<<0x0020::16, script_hash::bitstring-256>>, network)
  end

  def from_script_pub_key(
        <<0x0020::16, _script_hash::bitstring-256>> = script_pub_key,
        network \\ :mainnet
      ) do
    Bech32.from_script_pub_key(script_pub_key, network)
  end
end
