defmodule BitcoinLib.Key.HD.ExtendedPrivate do
  @moduledoc """
  Bitcoin extended private key management module
  """

  @max_index 0x7FFFFFFF
  @hardened 0x80000000

  @bitcoin_seed_hmac_key "Bitcoin seed"

  @private_key_length 32
  @version_bytes 0x0488ADE4

  # this is n, as found here https://en.bitcoin.it/wiki/Secp256k1
  @order_of_the_curve 0xFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFE_BAAEDCE6_AF48A03B_BFD25E8C_D0364141

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.{DerivationPath, ExtendedPublic}
  alias BitcoinLib.Key.HD.DerivationPath.{Level}

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
  @spec from_seed(String.t()) :: %{chain_code: Integer.t(), key: Integer.t()}
  def from_seed(seed) do
    seed
    |> Base.decode16!(case: :lower)
    |> Crypto.hmac_bitstring(@bitcoin_seed_hmac_key)
    |> split
    |> to_integers
  end

  @doc """
  Serialization of a master private key into its xpriv version

  ## Examples
    values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

    iex> primary_key = 0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35
    ...> chain_code = 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508
    ...> BitcoinLib.Key.HD.ExtendedPrivate.serialize_master_private_key(primary_key, chain_code)
    "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
  """
  def serialize_master_private_key(key, chain_code) do
    data = <<
      # "xprv"
      @version_bytes::size(32),
      # depth
      0::size(8),
      # index
      0::size(32),
      # parent's fingerprint
      0::size(32),
      # chain_code
      chain_code::size(256),
      # prepend of private key
      0::size(8),
      # private key
      key::size(256)
    >>

    <<
      data::bitstring,
      Crypto.checksum_bitstring(data)::bitstring
    >>
    |> Base58.encode()
  end

  @doc """
  Derives the nth child of a HD private key

  Takes a private key, its chain code and the child's index
  Returns the child's private key and it's associated chain code

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
  @spec derive_child(Integer.t(), Integer.t(), Integer.t()) :: {:ok, Integer.t(), Integer.t()}
  def derive_child(key, chain_code, index, is_hardened \\ false)

  def derive_child(key, chain_code, index, is_hardened)
      when is_integer(index) and index < @max_index do
    index =
      case is_hardened do
        true -> @hardened + index
        false -> index
      end

    %{child_private_key: child_private_key, child_chain_code: child_chain_code} =
      %{key: key, chain_code: chain_code, index: index}
      |> add_compressed_public_key
      |> compute_hmac_input
      |> compute_hmac
      |> compute_child_chain_code
      |> compute_child_private_key

    {:ok, child_private_key, child_chain_code}
  end

  @spec derive_child(Integer.t(), Integer.t(), Integer.t()) :: {:error, String.t()}
  def derive_child(_, _, index, _) when is_integer(index) do
    {:error, "#{index} is too large of an index"}
  end

  @spec from_derivation_path(Integer.t(), Integer.t(), %DerivationPath{}) ::
          {:ok, Integer.t(), Integer.t()}
  def from_derivation_path(key, chain_code, %DerivationPath{} = derivation_path) do
    {key, chain_code, _} =
      {key, chain_code, derivation_path}
      |> maybe_derive_purpose
      |> maybe_derive_coin_type
      |> maybe_derive_account
      |> maybe_derive_change
      |> maybe_derive_address_index

    {:ok, key, chain_code}
  end

  defp maybe_derive_purpose({key, chain_code, %DerivationPath{purpose: nil} = derivation_path}) do
    {key, chain_code, derivation_path}
  end

  defp maybe_derive_purpose(
         {key, chain_code, %DerivationPath{purpose: purpose} = derivation_path}
       ) do
    {:ok, key, chain_code} =
      case purpose do
        :bip44 -> derive_child(key, chain_code, 44, true)
        _ -> {:ok, key, chain_code}
      end

    {key, chain_code, derivation_path}
  end

  defp maybe_derive_coin_type(
         {key, chain_code, %DerivationPath{coin_type: nil} = derivation_path}
       ) do
    {key, chain_code, derivation_path}
  end

  defp maybe_derive_coin_type(
         {key, chain_code, %DerivationPath{coin_type: coin_type} = derivation_path}
       ) do
    {:ok, key, chain_code} =
      case coin_type do
        :bitcoin -> derive_child(key, chain_code, 0, true)
        :bitcoin_testnet -> derive_child(key, chain_code, 1, true)
        _ -> {:ok, key, chain_code}
      end

    {key, chain_code, derivation_path}
  end

  defp maybe_derive_account({key, chain_code, %DerivationPath{account: nil} = derivation_path}) do
    {key, chain_code, derivation_path}
  end

  defp maybe_derive_account(
         {key, chain_code,
          %DerivationPath{account: %Level{hardened?: true, value: account}} = derivation_path}
       ) do
    {:ok, key, chain_code} = derive_child(key, chain_code, account, true)

    {key, chain_code, derivation_path}
  end

  defp maybe_derive_change({key, chain_code, %DerivationPath{change: nil} = derivation_path}) do
    {key, chain_code, derivation_path}
  end

  defp maybe_derive_change({key, chain_code, %DerivationPath{change: change} = derivation_path}) do
    {:ok, key, chain_code} =
      case change do
        :receiving_chain -> derive_child(key, chain_code, 0, false)
        :change_chain -> derive_child(key, chain_code, 1, false)
        _ -> {:ok, key, chain_code}
      end

    {key, chain_code, derivation_path}
  end

  defp maybe_derive_address_index(
         {key, chain_code, %DerivationPath{address_index: nil} = derivation_path}
       ) do
    {key, chain_code, derivation_path}
  end

  defp maybe_derive_address_index(
         {key, chain_code,
          %DerivationPath{address_index: %Level{hardened?: false, value: index}} = derivation_path}
       ) do
    {:ok, key, chain_code} = derive_child(key, chain_code, index, true)

    {key, chain_code, derivation_path}
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

  # hmac_left_part and hmac_right_part are Il and Ir in slip-0010 as found here
  # https://github.com/satoshilabs/slips/blob/master/slip-0010.md#master-key-generation
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
