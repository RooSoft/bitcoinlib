defmodule BitcoinLib.Crypto.Wif do
  @moduledoc """
  WIF Bitcoin private key format management

  Inspired by https://learnmeabitcoin.com/technical/wif
  """

  alias BitcoinLib.Crypto
  alias BitcoinLib.Crypto.Convert

  @doc """
  Converts a raw private key to the WIF format

  ## Examples
    iex> 0x0A8D286B11B98F6CB2585B627FF44D12059560ACD430DCFA1260EF2BD9569373
    ...> |> BitcoinLib.Crypto.Wif.from_integer
    "KwaDo7PNi4XPMaABfSEo9rP6uviDUATAqvyjjWTcKp4fxdkVJWLe"
  """
  @spec from_integer(integer(), integer()) :: String.t()
  def from_integer(value, bytes_length \\ 32) do
    value
    |> Convert.integer_to_binary(bytes_length)
    |> binary_to_wif
  end

  defp binary_to_wif(bitstring_private_key) do
    bitstring_private_key
    |> add_prefix
    |> add_compressed
    |> add_checksum
    |> Base58.encode()
  end

  defp add_prefix(key) do
    <<0x80>> <> key
  end

  defp add_compressed(key) do
    key <> <<1>>
  end

  defp add_checksum(key) do
    checksum =
      key
      |> Crypto.checksum_bitstring()

    key <> checksum
  end
end
