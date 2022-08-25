defmodule BitcoinLib.Key.PublicKey.Address.Bech32 do
  @moduledoc """
  Implementation of Bech32 addresses

  BIP173: https://en.bitcoin.it/wiki/BIP_0173

  Sources:
  - https://en.bitcoin.it/wiki/Bech32
  - https://bitcointalk.org/index.php?topic=4992632.0
  """

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.PublicKey

  @doc """
  Creates a Bech32 address, which is starting by bc1, out of an Extended Public Key

  ## Examples
    iex> %BitcoinLib.Key.PublicKey{
    ...>  key: <<0x0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798::264>>,
    ...>  chain_code: 0
    ...> } |> BitcoinLib.Key.PublicKey.Address.Bech32.from_public_key()
    "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4"
  """
  def from_public_key(%PublicKey{key: key}, network \\ :mainnet) do
    key
    |> hash160
    |> to_base5_array
    |> prepend_witness_version(0)
    |> encode(network)
  end

  defp hash160(value) do
    value
    |> Crypto.hash160()
  end

  defp to_base5_array(value) do
    for <<chunk::size(5) <- value>> do
      chunk
    end
  end

  defp prepend_witness_version(base5array, witness_version) do
    [witness_version | base5array]
  end

  defp encode(base5array, :mainnet) do
    Bech32.encode("bc", base5array)
  end

  defp encode(base5array, :testnet) do
    Bech32.encode("tc", base5array)
  end
end
