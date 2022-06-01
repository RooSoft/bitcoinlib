defmodule BitcoinLib.Key.Private do
  alias BitcoinLib.Crypto.{Wif}

  @private_key_bits_length 256
  @private_key_bytes_length div(@private_key_bits_length, 8)
  @largest_key 0xFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFE_BAAE_DCE6_AF48_A03B_BFD2_5E8C_D036_4140

  def generate do
    raw = Enum.random(1..@largest_key)

    %{
      raw: raw,
      wif: raw |> Wif.from_integer(@private_key_bytes_length)
    }
  end

  # Based on https://learnmeabitcoin.com/technical/wif
  def to_wif(private_key) do
    private_key
    |> Wif.from_integer()
  end
end
