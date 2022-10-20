defmodule BitcoinLib.Key.PrivateKey do
  @moduledoc """
  Bitcoin extended private key management module
  """

  @enforce_keys [:key]
  defstruct [
    :key,
    :chain_code,
    depth: 0,
    index: 0,
    parent_fingerprint: <<0::32>>,
    fingerprint: <<0::32>>
  ]

  @bitcoin_seed_hmac_key "Bitcoin seed"

  @private_key_length 256
  @chain_code_length 256
  @version_bytes 0x0488ADE4
  @largest_key 0xFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFE_BAAE_DCE6_AF48_A03B_BFD2_5E8C_D036_4140

  require Logger

  alias BitcoinLib.Crypto
  alias BitcoinLib.Crypto.{Wif, Secp256k1}
  alias BitcoinLib.Key.{PrivateKey}
  alias BitcoinLib.Key.HD.{DerivationPath, Fingerprint, SeedPhrase}
  alias BitcoinLib.Key.PrivateKey.{ChildFromIndex, ChildFromDerivationPath}

  @doc """
  Converts a seed into a master private key hash containing the key itself and the chain code

  ## Examples
      iex> "7e4803bd0278e223532f5833d81605bedc5e16f39c49bdfff322ca83d444892ddb091969761ea406bee99d6ab613fad6a99a6d4beba66897b252f00c9dd7b364"
      ...> |> BitcoinLib.Key.PrivateKey.from_seed()
      %BitcoinLib.Key.PrivateKey{
        chain_code: <<0x5A7AEBB0FBE37BB89E690A6E350FAFED353B624741269E71001E608732FD8125::256>>,
        key: <<0x41DF6FA7F014A60FD79EC50B201FECF9CEDD8328921DDF670ACFCEF227242688::256>>,
        fingerprint: <<0xB317B417::32>>,
        parent_fingerprint: <<0::32>>
      }
  """
  @spec from_seed(binary()) :: %PrivateKey{}
  def from_seed(seed) do
    seed
    |> Base.decode16!(case: :lower)
    |> Crypto.hmac(@bitcoin_seed_hmac_key)
    |> split
    |> to_struct
  end

  @doc """
  Converts a seed phrase into an extended private key

  ## Examples
      iex> "rally celery split order almost twenty ignore record legend learn chaos decade"
      ...> |> BitcoinLib.Key.PrivateKey.from_seed_phrase()
      %BitcoinLib.Key.PrivateKey{
        fingerprint: <<0x2E92A74C::32>>,
        key: <<0xD6EAD233E06C068585976B5C8373861D77E7F030EC452E65EE81C85FA6906970::256>>,
        chain_code: <<0xA17100DD000D9D4A37034F7CEE0D46F5AE97B570BE065E57A00546FAE014A8A2::256>>,
        depth: 0x0,
        index: 0x0
      }
  """
  @spec from_seed_phrase(binary()) :: %PrivateKey{}
  def from_seed_phrase(seed_phrase, passphrase \\ "") do
    seed_phrase
    |> SeedPhrase.to_seed(passphrase)
    |> from_seed
  end

  @doc """
  Serialization of a master private key into its xpriv version

  values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

  ## Examples
      iex> %BitcoinLib.Key.PrivateKey {
      ...>   key: <<0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35::256>>,
      ...>   chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>
      ...> }
      ...> |> BitcoinLib.Key.PrivateKey.serialize()
      "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
  """
  @spec serialize(%PrivateKey{}) :: binary()
  def serialize(%PrivateKey{
        key: key,
        depth: depth,
        index: index,
        parent_fingerprint: parent_fingerprint,
        chain_code: chain_code
      }) do
    data = <<
      @version_bytes::32,
      depth::8,
      parent_fingerprint::bitstring-32,
      index::32,
      chain_code::bitstring-256,
      # prepend of private key
      0::8,
      key::bitstring-256
    >>

    <<
      data::bitstring,
      Crypto.checksum(data)::bitstring
    >>
    |> Base58.encode()
  end

  @doc """
  Deserialization of a private key from its xpriv version

  values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

  ## Examples
      iex> "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
      ...> |> BitcoinLib.Key.PrivateKey.deserialize()

      %BitcoinLib.Key.PrivateKey {
        key: <<0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35::256>>,
        chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>,
        depth: 0,
        index: 0
      }
  """
  @spec deserialize(binary()) :: %PrivateKey{}
  def deserialize(serialized_private_key) do
    <<
      @version_bytes::32,
      depth::8,
      parent_fingerprint::bitstring-32,
      index::32,
      chain_code::bitstring-256,
      # prepend of private key
      0::8,
      key::bitstring-256,
      _checksum::32
    >> =
      serialized_private_key
      |> Base58.decode()

    %PrivateKey{
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
      iex> private_key = %BitcoinLib.Key.PrivateKey{
      ...>   key: <<0xf79bb0d317b310b261a55a8ab393b4c8a1aba6fa4d08aef379caba502d5d67f9::256>>,
      ...>   chain_code: <<0x463223aac10fb13f291a1bc76bc26003d98da661cb76df61e750c139826dea8b::256>>
      ...> }
      ...> index = 0
      ...> BitcoinLib.Key.PrivateKey.derive_child(private_key, index)
      {
        :ok,
        %BitcoinLib.Key.PrivateKey{
          key: <<0x39f329fedba2a68e2a804fcd9aeea4104ace9080212a52ce8b52c1fb89850c72::256>>,
          chain_code: <<0x05aae71d7c080474efaab01fa79e96f4c6cfe243237780b0df4bc36106228e31::256>>,
          depth: 1,
          index: 0,
          parent_fingerprint: <<0x18C1259::32>>
        }
      }
  """
  @spec derive_child(%PrivateKey{}, integer(), boolean()) :: {:ok, %PrivateKey{}}
  def derive_child(private_key, index, hardened? \\ false) do
    ChildFromIndex.get(private_key, index, hardened?)
  end

  @doc """
  Simply calls from_derivation_path and directly returns the private key whatever the outcome.any()
  Will crash if the index is negative or greater than 0x7FFFFFFF

  ## Examples
      iex> private_key = %BitcoinLib.Key.PrivateKey{
      ...>   key: <<0xf79bb0d317b310b261a55a8ab393b4c8a1aba6fa4d08aef379caba502d5d67f9::256>>,
      ...>   chain_code: <<0x463223aac10fb13f291a1bc76bc26003d98da661cb76df61e750c139826dea8b::256>>
      ...> }
      ...> index = 0
      ...> BitcoinLib.Key.PrivateKey.derive_child!(private_key, index)
      %BitcoinLib.Key.PrivateKey{
        key: <<0x39f329fedba2a68e2a804fcd9aeea4104ace9080212a52ce8b52c1fb89850c72::256>>,
        chain_code: <<0x05aae71d7c080474efaab01fa79e96f4c6cfe243237780b0df4bc36106228e31::256>>,
        depth: 1,
        index: 0,
        parent_fingerprint: <<0x18C1259::32>>
      }
  """
  @spec derive_child!(%PrivateKey{}, integer(), boolean()) :: %PrivateKey{}
  def derive_child!(private_key, index, hardened? \\ false) do
    derive_child(private_key, index, hardened?)
    |> elem(1)
  end

  @doc """
  Derives a child private key, following a derivation path

  ## Examples
      iex> private_key = %BitcoinLib.Key.PrivateKey{
      ...>   key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      ...>   chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
      ...> }
      ...> {:ok, derivation_path} = BitcoinLib.Key.HD.DerivationPath.parse("m/44'")
      ...> BitcoinLib.Key.PrivateKey.from_derivation_path(private_key, derivation_path)
      {
        :ok,
        %BitcoinLib.Key.PrivateKey{
          key: <<0x4E59086C1DEC6D081986CB079F536E38B3D2B6DA7A8EDCFFB1942AE8B9FDF156::256>>,
          chain_code: <<0xF42DE823EE78F6227822D79BC6F6101D084D7F0F876B7828BF027D681294E538::256>>,
          depth: 1,
          index: 0x8000002C,
          parent_fingerprint: <<0x18C1259::32>>
        }
      }
  """
  @spec from_derivation_path(%PrivateKey{}, %DerivationPath{}) :: {:ok, %PrivateKey{}}
  def from_derivation_path(%PrivateKey{} = private_key, %DerivationPath{} = derivation_path) do
    ChildFromDerivationPath.get(private_key, derivation_path)
  end

  @spec from_derivation_path(%PrivateKey{}, binary()) :: {:ok, %PrivateKey{}}
  def from_derivation_path(%PrivateKey{} = private_key, derivation_path_string)
      when is_binary(derivation_path_string) do
    {:ok, derivation_path} = DerivationPath.parse(derivation_path_string)

    from_derivation_path(private_key, derivation_path)
  end

  @doc """
  Simply calls from_derivation_path and directly returns the private key whatever the outcome.any()
  Will crash if used with an invalid derivation path

  ## Examples
      iex> private_key = %BitcoinLib.Key.PrivateKey{
      ...>   key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      ...>   chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
      ...> }
      ...> {:ok, derivation_path} = BitcoinLib.Key.HD.DerivationPath.parse("m/44'")
      ...> BitcoinLib.Key.PrivateKey.from_derivation_path!(private_key, derivation_path)
      %BitcoinLib.Key.PrivateKey{
        key: <<0x4E59086C1DEC6D081986CB079F536E38B3D2B6DA7A8EDCFFB1942AE8B9FDF156::256>>,
        chain_code: <<0xF42DE823EE78F6227822D79BC6F6101D084D7F0F876B7828BF027D681294E538::256>>,
        depth: 1,
        index: 0x8000002C,
        parent_fingerprint: <<0x18C1259::32>>
      }
  """
  @spec from_derivation_path!(%PrivateKey{}, %DerivationPath{}) :: %PrivateKey{}
  def from_derivation_path!(%PrivateKey{} = private_key, %DerivationPath{} = derivation_path) do
    from_derivation_path(private_key, derivation_path)
    |> elem(1)
  end

  @spec from_derivation_path!(%PrivateKey{}, binary()) :: %PrivateKey{}
  def from_derivation_path!(%PrivateKey{} = private_key, derivation_path_string)
      when is_binary(derivation_path_string) do
    from_derivation_path(private_key, derivation_path_string)
    |> elem(1)
  end

  @doc """
  Creates a Bitcoin private key using efficient randomness

  Inspired by https://learnmeabitcoin.com/technical/private-key

  ## Examples
      iex> %{raw: raw1} = BitcoinLib.Key.PrivateKey.generate
      ...> %{raw: raw2} = BitcoinLib.Key.PrivateKey.generate
      ...> raw1 == raw2
      false
  """
  @spec generate() :: %{raw: bitstring(), wif: binary()}
  def generate do
    random_number = Enum.random(1..@largest_key)

    raw = <<random_number::size(@private_key_length)>>

    %{
      raw: raw,
      wif: raw |> Wif.from_bitstring()
    }
  end

  @doc """
  Converts a private key to the WIF format

  Based on https://learnmeabitcoin.com/technical/wif

  ## Examples
      iex> %BitcoinLib.Key.PrivateKey{key: <<108, 122, 178, 249, 97, 161, 188, 63, 19, 205, 192, 141,
      ...>   196, 28, 63, 67, 154, 222, 189, 84, 154, 142, 241, 192, 137, 232, 26, 89,
      ...>   7, 55, 97, 7>>}
      ...> |> BitcoinLib.Key.PrivateKey.to_wif()
      "KzractrYn5gnDNVwBDy7sYhAkyMvX4WeYQpwyhCAUKDogJTzYsUc"
  """
  def to_wif(%PrivateKey{key: key}) do
    key
    |> Wif.from_bitstring()
  end

  @doc """
  Create a private key from a WIF

  Based on https://learnmeabitcoin.com/technical/wif

  ## Examples
      iex> "KzractrYn5gnDNVwBDy7sYhAkyMvX4WeYQpwyhCAUKDogJTzYsUc"
      ...> |> BitcoinLib.Key.PrivateKey.from_wif()
      %BitcoinLib.Key.PrivateKey{key: <<108, 122, 178, 249, 97, 161, 188, 63, 19, 205, 192, 141,
       196, 28, 63, 67, 154, 222, 189, 84, 154, 142, 241, 192, 137, 232, 26, 89,
       7, 55, 97, 7>>}
  """
  def from_wif(wif) do
    key =
      wif
      |> Wif.to_private_key()

    %PrivateKey{key: key}
  end

  @doc """
  Signs a message using a private key

  Below is an example of a signature... this doctest doesn't end with a value, because the signature
  is different on every call, and even can have different lengths.

  ## Examples
      iex> message = "76a914c825a1ecf2a6830c4401620c3a16f1995057c2ab88ac"
      ...> private_key = %BitcoinLib.Key.PrivateKey{key: <<0xd6ead233e06c068585976b5c8373861d77e7f030ec452e65ee81c85fa6906970::256>>}
      ...> BitcoinLib.Crypto.Secp256k1.sign(message, private_key)
  """
  @spec sign_message(binary(), %PrivateKey{}) :: binary()
  def sign_message(message, private_key) do
    message
    |> Secp256k1.sign(private_key)
  end

  defp split(extended_private_key) do
    <<private_key::bitstring-@private_key_length, chain_code::bitstring-@chain_code_length>> =
      extended_private_key

    %{
      key: private_key,
      chain_code: chain_code
    }
  end

  defp to_struct(%{key: private_key, chain_code: chain_code}) do
    %PrivateKey{
      key: private_key,
      chain_code: chain_code,
      depth: 0,
      index: 0
    }
    |> add_fingerprint()
  end

  defp add_fingerprint(%PrivateKey{} = private_key) do
    private_key
    |> Map.put(:fingerprint, Fingerprint.compute(private_key))
  end
end

defimpl Inspect, for: BitcoinLib.Key.PrivateKey do
  alias BitcoinLib.Key.PrivateKey
  alias BitcoinLib.Formatting.HexBinary

  def inspect(%PrivateKey{} = private_key, opts) do
    %{
      private_key
      | key: %HexBinary{data: private_key.key},
        chain_code: %HexBinary{data: private_key.chain_code},
        fingerprint: %HexBinary{data: private_key.fingerprint},
        parent_fingerprint: %HexBinary{data: private_key.parent_fingerprint}
    }
    |> Inspect.Any.inspect(opts)
  end
end
