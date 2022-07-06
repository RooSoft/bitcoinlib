defmodule BitcoinLib.Key.Private do
  @moduledoc """
  Bitcoin private key management module
  """

  alias BitcoinLib.Crypto.{Wif}

  @private_key_bits_length 256
  @private_key_bytes_length div(@private_key_bits_length, 8)
  @largest_key 0xFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFE_BAAE_DCE6_AF48_A03B_BFD2_5E8C_D036_4140

  @doc """
  Creates a Bitcoin private key using efficient randomness

  Inspired by https://learnmeabitcoin.com/technical/private-key

  ## Examples

    iex> %{raw: raw1} = BitcoinLib.Key.Private.generate
    ...> %{raw: raw2} = BitcoinLib.Key.Private.generate
    ...> raw1 == raw2
    false
  """
  @spec generate() :: %{raw: integer(), wif: String.t()}
  def generate do
    raw = Enum.random(1..@largest_key)

    %{
      raw: raw,
      wif: raw |> Wif.from_integer(@private_key_bytes_length)
    }
  end

  @doc """
  Converts a binary primary key to the WIF format

  Based on https://learnmeabitcoin.com/technical/wif

  ## Examples

    iex> 0x6C7AB2F961A1BC3F13CDC08DC41C3F439ADEBD549A8EF1C089E81A5907376107
    ...> |> BitcoinLib.Key.Private.to_wif()
    "KzractrYn5gnDNVwBDy7sYhAkyMvX4WeYQpwyhCAUKDogJTzYsUc"
  """
  def to_wif(private_key) do
    private_key
    |> Wif.from_integer()
  end
end
