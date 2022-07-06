defmodule BitcoinLib.Key.HD.ExtendedPublic.Address.Bech32 do
  @moduledoc """
  Implementation of Bech32 addresses

  BIP173: https://en.bitcoin.it/wiki/BIP_0173

  Sources:
  - https://en.bitcoin.it/wiki/Bech32
  - https://bitcointalk.org/index.php?topic=4992632.0
  """

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.ExtendedPublic

  @doc """
  Creates a Bech32 address, which is starting by bc1, out of an Extended Public Key

  ## Examples
    iex> %BitcoinLib.Key.HD.ExtendedPublic{
    ...>  key: 0x0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
    ...>  chain_code: 0
    ...> } |> BitcoinLib.Key.HD.ExtendedPublic.Address.Bech32.from_extended_public_key()
    "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4"
  """
  def from_extended_public_key(%ExtendedPublic{key: key}) do
    key
    |> to_binary
    |> hash160
    |> to_base5_array
    |> prepend_witness_version(0)
    |> encode
  end

  defp to_binary(key) do
    key
    |> Binary.from_integer()
  end

  defp hash160(value) do
    value
    |> Crypto.hash160_bitstring()
  end

  defp to_base5_array(value) do
    for <<chunk::size(5) <- value>> do
      chunk
    end
  end

  defp prepend_witness_version(base5array, witness_version) do
    [witness_version | base5array]
  end

  defp encode(base5array) do
    Bech32.encode("bc", base5array)
  end
end
