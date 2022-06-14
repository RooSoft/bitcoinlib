defmodule BitcoinLib.Key.HD.ExtendedPrivate do
  @moduledoc """
  Bitcoin extended private key management module
  """

  @max_index 2_147_483_647

  @bitcoin_seed_hmac_key "Bitcoin seed"

  @private_key_length 32

  # this is n, as found here https://en.bitcoin.it/wiki/Secp256k1
  @order_of_the_curve 0xFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFE_BAAEDCE6_AF48A03B_BFD25E8C_D0364141

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.{ExtendedPublic}

  @doc """
  Converts a seed into a master private key hash containing the key itself and the chain code

  ## Examples
    iex> "7e4803bd0278e223532f5833d81605bedc5e16f39c49bdfff322ca83d444892ddb091969761ea406bee99d6ab613fad6a99a6d4beba66897b252f00c9dd7b364"
    ...> |> BitcoinLib.Key.HD.ExtendedPrivate.from_seed()
    %{
      chain_code: 0x5A7AEBB0FBE37BB89E690A6E350FAFED353B624741269E71001E608732FD8125,
      key: 0x41DF6FA7F014A60FD79EC50B201FECF9CEDD8328921DDF670ACFCEF227242688
    }
  """
  @spec from_seed(Integer.t()) :: %{chain_code: Integer.t(), key: Integer.t()}
  def from_seed(seed) do
    seed
    |> Base.decode16!(case: :lower)
    |> Crypto.hmac_bitstring(@bitcoin_seed_hmac_key)
    |> split
    |> to_integers
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
    %{child_private_key: child_private_key, child_chain_code: child_chain_code} =
      %{key: key, chain_code: chain_code, index: index}
      |> add_compressed_public_key
      |> compute_hmac_input
      |> compute_hmac
      |> compute_child_chain_code
      |> compute_child_private_key

    {:ok, child_private_key, child_chain_code}
  end

  def derive_child(_, _, index) do
    {:error, "#{index} is too large of an index"}
  end

  defp add_compressed_public_key(%{key: key} = hash) do
    {_uncompressed_public_key, compressed_public_key} =
      key
      |> ExtendedPublic.from_private_key()

    hash
    |> Map.put(:compressed_public_key, compressed_public_key)
  end

  defp compute_hmac_input(%{compressed_public_key: compressed_public_key, index: index} = hash) do
    binary_public_key = Binary.from_integer(compressed_public_key)

    hmac_input = <<binary_public_key::bitstring, index::size(32)>> |> Binary.to_integer()

    hash
    |> Map.put(:hmac_input, hmac_input)
  end

  defp compute_hmac(%{hmac_input: hmac_input, chain_code: chain_code} = hash) do
    {hmac_left_part, hmac_right_part} =
      hmac_input
      |> Binary.from_integer()
      |> Crypto.hmac_bitstring(chain_code |> Binary.from_integer())
      |> String.split_at(32)

    hash
    |> Map.put(:hmac_left_part, hmac_left_part)
    |> Map.put(:hmac_right_part, hmac_right_part)
  end

  defp compute_child_chain_code(%{hmac_right_part: hmac_right_part} = hash) do
    hash
    |> Map.put(:child_chain_code, hmac_right_part |> Binary.to_integer())
  end

  defp compute_child_private_key(%{key: key, hmac_left_part: hmac_left_part} = hash) do
    child_private_key =
      (Binary.to_integer(hmac_left_part) + key)
      |> rem(@order_of_the_curve)

    hash
    |> Map.put(:child_private_key, child_private_key)
  end

  defp split(extended_private_key) do
    <<private_key::binary-@private_key_length, chain_code::binary-@private_key_length>> =
      extended_private_key

    %{
      key: private_key,
      chain_code: chain_code
    }
  end

  defp to_integers(%{key: private_key, chain_code: chain_code}) do
    %{
      key: Binary.to_integer(private_key),
      chain_code: Binary.to_integer(chain_code)
    }
  end
end
