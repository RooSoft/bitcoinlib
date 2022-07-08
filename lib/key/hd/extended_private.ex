defmodule BitcoinLib.Key.HD.ExtendedPrivate do
  @moduledoc """
  Bitcoin extended private key management module
  """

  @enforce_keys [:key, :chain_code]
  defstruct [:key, :chain_code, depth: 0, index: 0, parent_fingerprint: 0, fingerprint: 0]

  @bitcoin_seed_hmac_key "Bitcoin seed"

  @private_key_length 32
  @version_bytes 0x0488ADE4

  require Logger

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.{DerivationPath, ExtendedPrivate, Fingerprint, MnemonicSeed}
  alias BitcoinLib.Key.HD.ExtendedPrivate.{ChildFromIndex, ChildFromDerivationPath}

  @doc """
  Converts a seed into a master private key hash containing the key itself and the chain code

  ## Examples
    iex> "7e4803bd0278e223532f5833d81605bedc5e16f39c49bdfff322ca83d444892ddb091969761ea406bee99d6ab613fad6a99a6d4beba66897b252f00c9dd7b364"
    ...> |> BitcoinLib.Key.HD.ExtendedPrivate.from_seed()
    %BitcoinLib.Key.HD.ExtendedPrivate{
      chain_code: 0x5A7AEBB0FBE37BB89E690A6E350FAFED353B624741269E71001E608732FD8125,
      key: 0x41DF6FA7F014A60FD79EC50B201FECF9CEDD8328921DDF670ACFCEF227242688,
      fingerprint: 0xB317B417
    }
  """
  @spec from_seed(binary()) :: %ExtendedPrivate{}
  def from_seed(seed) do
    seed
    |> Base.decode16!(case: :lower)
    |> Crypto.hmac_bitstring(@bitcoin_seed_hmac_key)
    |> split
    |> to_struct
  end

  @doc """
  Converts a mnemonic phrase into an extended private key

  ## Examples
    iex> "rally celery split order almost twenty ignore record legend learn chaos decade"
    ...> |> BitcoinLib.Key.HD.ExtendedPrivate.from_mnemonic_phrase()
    %BitcoinLib.Key.HD.ExtendedPrivate{
      fingerprint: 0x2E92A74C,
      key: 0xD6EAD233E06C068585976B5C8373861D77E7F030EC452E65EE81C85FA6906970,
      chain_code: 0xA17100DD000D9D4A37034F7CEE0D46F5AE97B570BE065E57A00546FAE014A8A2,
      depth: 0x0,
      index: 0x0
    }
  """
  @spec from_mnemonic_phrase(binary()) :: %ExtendedPrivate{}
  def from_mnemonic_phrase(mnemonic_phrase, passphrase \\ "") do
    mnemonic_phrase
    |> MnemonicSeed.to_seed(passphrase)
    |> from_seed
  end

  @doc """
  Serialization of a master private key into its xpriv version

  ## Examples
    values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

    iex> %BitcoinLib.Key.HD.ExtendedPrivate {
    ...>   key: 0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35,
    ...>   chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPrivate.serialize()
    "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
  """
  @spec serialize(%ExtendedPrivate{}) :: binary()
  def serialize(%ExtendedPrivate{
        key: key,
        depth: depth,
        index: index,
        parent_fingerprint: parent_fingerprint,
        chain_code: chain_code
      }) do
    data = <<
      @version_bytes::size(32),
      depth::size(8),
      parent_fingerprint::size(32),
      index::size(32),
      chain_code::size(256),
      # prepend of private key
      0::size(8),
      key::size(256)
    >>

    <<
      data::bitstring,
      Crypto.checksum_bitstring(data)::bitstring
    >>
    |> Base58.encode()
  end

  @doc """
  Deserialization of a private key from its xpriv version

  ## Examples
    values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

    iex> "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
    ...> |> BitcoinLib.Key.HD.ExtendedPrivate.deserialize()

    %BitcoinLib.Key.HD.ExtendedPrivate {
      key: 0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35,
      chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508,
      depth: 0,
      index: 0,
      parent_fingerprint: 0
    }
  """
  @spec deserialize(binary()) :: %ExtendedPrivate{}
  def deserialize(serialized_private_key) do
    <<
      @version_bytes::size(32),
      depth::size(8),
      parent_fingerprint::size(32),
      index::size(32),
      chain_code::size(256),
      # prepend of private key
      0::size(8),
      key::size(256),
      _checksum::size(32)
    >> =
      serialized_private_key
      |> Base58.decode()

    %ExtendedPrivate{
      key: key,
      chain_code: chain_code,
      depth: depth,
      index: index,
      parent_fingerprint: parent_fingerprint
    }
  end

  @doc """
  Derives the nth child of a HD private key

  Takes a private key, its chain code and the child's index
  Returns the child's private key and it's associated chain code

  Inspired by https://learnmeabitcoin.com/technical/extended-keys#child-extended-key-derivation

  ## Examples

    iex> private_key = %BitcoinLib.Key.HD.ExtendedPrivate{
    ...>   key: 0xf79bb0d317b310b261a55a8ab393b4c8a1aba6fa4d08aef379caba502d5d67f9,
    ...>   chain_code: 0x463223aac10fb13f291a1bc76bc26003d98da661cb76df61e750c139826dea8b
    ...> }
    ...> index = 0
    ...> BitcoinLib.Key.HD.ExtendedPrivate.derive_child(private_key, index)
    {
      :ok,
      %BitcoinLib.Key.HD.ExtendedPrivate{
        key: 0x39f329fedba2a68e2a804fcd9aeea4104ace9080212a52ce8b52c1fb89850c72,
        chain_code: 0x05aae71d7c080474efaab01fa79e96f4c6cfe243237780b0df4bc36106228e31,
        depth: 1,
        index: 0,
        parent_fingerprint: 0x18C1259
      }
    }
  """
  @spec derive_child(%ExtendedPrivate{}, integer(), boolean()) :: {:ok, %ExtendedPrivate{}}
  def derive_child(private_key, index, hardened? \\ false) do
    ChildFromIndex.get(private_key, index, hardened?)
  end

  @doc """
  Simply calls from_derivation_path and directly returns the private key whatever the outcome.any()
  Will crash if the index is negative or greater than 0x7FFFFFFF

  ## Examples
    iex> private_key = %BitcoinLib.Key.HD.ExtendedPrivate{
    ...>   key: 0xf79bb0d317b310b261a55a8ab393b4c8a1aba6fa4d08aef379caba502d5d67f9,
    ...>   chain_code: 0x463223aac10fb13f291a1bc76bc26003d98da661cb76df61e750c139826dea8b
    ...> }
    ...> index = 0
    ...> BitcoinLib.Key.HD.ExtendedPrivate.derive_child!(private_key, index)
    %BitcoinLib.Key.HD.ExtendedPrivate{
      key: 0x39f329fedba2a68e2a804fcd9aeea4104ace9080212a52ce8b52c1fb89850c72,
      chain_code: 0x05aae71d7c080474efaab01fa79e96f4c6cfe243237780b0df4bc36106228e31,
      depth: 1,
      index: 0,
      parent_fingerprint: 0x18C1259
    }
  """
  @spec derive_child!(%ExtendedPrivate{}, integer(), boolean()) :: %ExtendedPrivate{}
  def derive_child!(private_key, index, hardened? \\ false) do
    derive_child(private_key, index, hardened?)
    |> elem(1)
  end

  @doc """
  Derives a child private key, following a derivation path

  ## Examples
    iex> private_key = %BitcoinLib.Key.HD.ExtendedPrivate{
    ...>   key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
    ...>   chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    ...> }
    ...> {:ok, derivation_path} = BitcoinLib.Key.HD.DerivationPath.parse("m/44'")
    ...> BitcoinLib.Key.HD.ExtendedPrivate.from_derivation_path(private_key, derivation_path)
    {
      :ok,
      %BitcoinLib.Key.HD.ExtendedPrivate{
        key: 0x4E59086C1DEC6D081986CB079F536E38B3D2B6DA7A8EDCFFB1942AE8B9FDF156,
        chain_code: 0xF42DE823EE78F6227822D79BC6F6101D084D7F0F876B7828BF027D681294E538,
        depth: 1,
        index: 0x8000002C,
        parent_fingerprint: 0x18C1259
      }
    }
  """
  @spec from_derivation_path(%ExtendedPrivate{}, %DerivationPath{}) :: {:ok, %ExtendedPrivate{}}
  def from_derivation_path(%ExtendedPrivate{} = private_key, %DerivationPath{} = derivation_path) do
    ChildFromDerivationPath.get(private_key, derivation_path)
  end

  @spec from_derivation_path(%ExtendedPrivate{}, binary()) :: {:ok, %ExtendedPrivate{}}
  def from_derivation_path(%ExtendedPrivate{} = private_key, derivation_path_string)
      when is_binary(derivation_path_string) do
    {:ok, derivation_path} = DerivationPath.parse(derivation_path_string)

    from_derivation_path(private_key, derivation_path)
  end

  @doc """
  Simply calls from_derivation_path and directly returns the private key whatever the outcome.any()
  Will crash if used with an invalid derivation path

  ## Examples
    iex> private_key = %BitcoinLib.Key.HD.ExtendedPrivate{
    ...>   key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
    ...>   chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    ...> }
    ...> {:ok, derivation_path} = BitcoinLib.Key.HD.DerivationPath.parse("m/44'")
    ...> BitcoinLib.Key.HD.ExtendedPrivate.from_derivation_path!(private_key, derivation_path)
    %BitcoinLib.Key.HD.ExtendedPrivate{
      key: 0x4E59086C1DEC6D081986CB079F536E38B3D2B6DA7A8EDCFFB1942AE8B9FDF156,
      chain_code: 0xF42DE823EE78F6227822D79BC6F6101D084D7F0F876B7828BF027D681294E538,
      depth: 1,
      index: 0x8000002C,
      parent_fingerprint: 0x18C1259
    }
  """
  @spec from_derivation_path!(%ExtendedPrivate{}, %DerivationPath{}) :: %ExtendedPrivate{}
  def from_derivation_path!(%ExtendedPrivate{} = private_key, %DerivationPath{} = derivation_path) do
    from_derivation_path(private_key, derivation_path)
    |> elem(1)
  end

  @spec from_derivation_path!(%ExtendedPrivate{}, binary()) :: %ExtendedPrivate{}
  def from_derivation_path!(%ExtendedPrivate{} = private_key, derivation_path_string)
      when is_binary(derivation_path_string) do
    from_derivation_path(private_key, derivation_path_string)
    |> elem(1)
  end

  defp split(extended_private_key) do
    <<private_key::binary-@private_key_length, chain_code::binary-@private_key_length>> =
      extended_private_key

    %{
      key: private_key,
      chain_code: chain_code
    }
  end

  defp to_struct(%{key: binary_private_key, chain_code: chain_code}) do
    private_key = Binary.to_integer(binary_private_key)

    %ExtendedPrivate{
      key: private_key,
      chain_code: Binary.to_integer(chain_code),
      depth: 0,
      index: 0,
      parent_fingerprint: 0
    }
    |> add_fingerprint()
  end

  defp add_fingerprint(%ExtendedPrivate{} = private_key) do
    private_key
    |> Map.put(:fingerprint, Fingerprint.compute(private_key))
  end
end
