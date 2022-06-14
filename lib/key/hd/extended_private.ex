defmodule BitcoinLib.Key.HD.ExtendedPrivate do
  @moduledoc """
  Bitcoin extended private key management module
  """

  @max_index 2_147_483_647

  @bitcoin_seed_hmac_key "Bitcoin seed"
  @hexadecimal 16
  @private_key_length 32
  @private_key_length_string_format @private_key_length * 2

  # this is n, as found here https://en.bitcoin.it/wiki/Secp256k1
  @order_of_the_curve 0xFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFE_BAAEDCE6_AF48A03B_BFD25E8C_D0364141

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.{ExtendedPublic}

  def from_seed(seed) do
    seed
    |> Base.decode16!(case: :lower)
    |> Crypto.hmac_bitstring(@bitcoin_seed_hmac_key)
    |> split
  end

  @doc """
  Derives the nth child of a HD private key

  Inspired by https://learnmeabitcoin.com/technical/extended-keys#child-extended-key-derivation

  ## Examples

    iex> private_key = 0xf79bb0d317b310b261a55a8ab393b4c8a1aba6fa4d08aef379caba502d5d67f9
    ...> chain_code = 0x463223aac10fb13f291a1bc76bc26003d98da661cb76df61e750c139826dea8b
    ...> index = 0
    ...> BitcoinLib.Key.HD.ExtendedPrivate.derive_child(private_key, chain_code, index)
    {
      :ok,
      0x39f329fedba2a68e2a804fcd9aeea4104ace9080212a52ce8b52c1fb89850c72,
      0x05aae71d7c080474efaab01fa79e96f4c6cfe243237780b0df4bc36106228e31
    }
  """
  def derive_child(key, chain_code, index) when index < @max_index do
    {_uncompressed_public_key, compressed_public_key} =
      key
      |> ExtendedPublic.from_private_key()

    binary_public_key = Binary.from_hex(compressed_public_key)

    hmac_input = <<binary_public_key::bitstring, index::size(32)>> |> Binary.to_integer()

    {hmac_left_part, hmac_right_part} =
      hmac_input
      |> Binary.from_integer()
      |> Crypto.hmac_bitstring(chain_code |> Binary.from_integer())
      |> String.split_at(32)

    child_chain_code = Binary.to_integer(hmac_right_part)

    child_private_key =
      (Binary.to_integer(hmac_left_part) + key)
      |> rem(@order_of_the_curve)

    child_private_key
    |> Integer.to_string(@hexadecimal)
    |> String.pad_leading(@private_key_length_string_format, "0")
    |> String.downcase()

    child_private_key |> ExtendedPublic.from_private_key()

    {:ok, child_private_key, child_chain_code}
  end

  def derive_child(_, _, index) do
    {:error, "#{index} is too large of an index"}
  end

  defp split(extended_private_key) do
    <<private_key::binary-@private_key_length, chain_code::binary-@private_key_length>> =
      extended_private_key

    %{
      key: private_key,
      chain_code: chain_code
    }
  end
end
