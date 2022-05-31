defmodule BitcoinLib.Key.Private do
  alias BitcoinLib.Crypto

  def generate do
    private_key = :crypto.strong_rand_bytes(32)

    case valid?(private_key) do
      true -> private_key
      false -> private_key
    end
  end

  # Based on https://learnmeabitcoin.com/technical/wif
  def to_wif(private_key) do
    private_key
    |> String.upcase()
    |> add_prefix
    |> add_compressed
    |> add_checksum
    |> Base.decode16!()
    |> Base58.encode()
  end

  defp add_prefix(key) do
    "80#{key}"
  end

  defp add_compressed(key) do
    "#{key}01"
  end

  defp add_checksum(key) do
    checksum =
      key
      |> Crypto.checksum()

    "#{key}#{checksum}"
  end

  defp valid?(key) when is_binary(key) do
    key
    |> :binary.decode_unsigned()
    |> valid?
  end

  @n :binary.decode_unsigned(<<
       0xFF,
       0xFF,
       0xFF,
       0xFF,
       0xFF,
       0xFF,
       0xFF,
       0xFF,
       0xFF,
       0xFF,
       0xFF,
       0xFF,
       0xFF,
       0xFF,
       0xFF,
       0xFE,
       0xBA,
       0xAE,
       0xDC,
       0xE6,
       0xAF,
       0x48,
       0xA0,
       0x3B,
       0xBF,
       0xD2,
       0x5E,
       0x8C,
       0xD0,
       0x36,
       0x41,
       0x41
     >>)
  defp valid?(key) when key > 1 and key < @n, do: true
  defp valid?(_), do: false
end
