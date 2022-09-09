defmodule BitcoinLib.Crypto.Wif do
  @moduledoc """
  WIF Bitcoin private key format management

  Inspired by https://learnmeabitcoin.com/technical/wif
  """

  alias BitcoinLib.Crypto

  @mainnet 0x80
  @testnet 0xEF

  @doc """
  Converts a raw private key to the WIF format

  ## Examples
    iex> <<10, 141, 40, 107, 17, 185, 143, 108, 178, 88, 91, 98, 127, 244, 77, 18, 5,
    ...> 149, 96, 172, 212, 48, 220, 250, 18, 96, 239, 43, 217, 86, 147, 115>>
    ...> |> BitcoinLib.Crypto.Wif.from_bitstring
    "KwaDo7PNi4XPMaABfSEo9rP6uviDUATAqvyjjWTcKp4fxdkVJWLe"
  """
  @spec from_bitstring(bitstring()) :: String.t()
  def from_bitstring(value) do
    value
    |> add_prefix
    |> add_compressed
    |> add_checksum
    |> Base58.encode()
  end

  def to_private_key(wif) do
    IO.inspect wif
    wif
    |> Base58.decode()
    |> decode_private_key |> IO.inspect
  end

  defp add_prefix(key) do
    <<0x80>> <> key
  end

  defp add_compressed(key) do
    key <> <<1>>
  end

  defp add_checksum(key) do
    key <> Crypto.checksum(key)
  end

  defp decode_private_key(<<@mainnet::8, key::bitstring-256, _compressed?::8, _checksum::32>>) do
    key
  end

  defp decode_private_key(<<@testnet::8, key::bitstring-256, _compressed?::8, _checksum::32>>) do
    key
  end
end
