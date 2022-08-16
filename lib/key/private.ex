defmodule BitcoinLib.Key.Private do
  @moduledoc """
  Bitcoin private key management module
  """

  alias BitcoinLib.Crypto.{Wif, Secp256k1}

  @private_key_bits_length 256
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
  @spec generate() :: %{raw: bitstring(), wif: binary()}
  def generate do
    random_number = Enum.random(1..@largest_key)

    raw = <<random_number::size(@private_key_bits_length)>>

    %{
      raw: raw,
      wif: raw |> Wif.from_bitstring()
    }
  end

  @doc """
  Converts a binary primary key to the WIF format

  Based on https://learnmeabitcoin.com/technical/wif

  ## Examples

    iex> <<108, 122, 178, 249, 97, 161, 188, 63, 19, 205, 192, 141, 196, 28, 63, 67, 154,
    ...> 222, 189, 84, 154, 142, 241, 192, 137, 232, 26, 89, 7, 55, 97, 7>>
    ...> |> BitcoinLib.Key.Private.to_wif()
    "KzractrYn5gnDNVwBDy7sYhAkyMvX4WeYQpwyhCAUKDogJTzYsUc"
  """
  def to_wif(private_key) do
    private_key
    |> Wif.from_bitstring()
  end

  @doc """
  Signs a message using a private key

  Below is an example of a signature... this doctest doesn't end with a value, because the signature
  is different on every call, and even can have different lengths.

  ## Examples
    iex> message = "76a914c825a1ecf2a6830c4401620c3a16f1995057c2ab88ac"
    ...> private_key = <<0xd6ead233e06c068585976b5c8373861d77e7f030ec452e65ee81c85fa6906970::256>>
    ...> BitcoinLib.Crypto.Secp256k1.sign(message, private_key)
  """
  def sign_message(message, private_key) do
    message
    |> Secp256k1.sign(private_key)
  end
end
