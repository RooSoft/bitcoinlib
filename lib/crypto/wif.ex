defmodule BitcoinLib.Crypto.Wif do
  alias BitcoinLib.Crypto
  alias BitcoinLib.Crypto.Convert

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
