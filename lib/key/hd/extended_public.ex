defmodule BitcoinLib.Key.HD.ExtendedPublic do
  @moduledoc """
  Bitcoin extended public key management module
  """

  @enforce_keys [:key, :chain_code]
  defstruct [
    :key,
    :chain_code,
    depth: 0,
    index: 0,
    parent_fingerprint: <<0::32>>,
    fingerprint: <<0::32>>
  ]

  alias BitcoinLib.Key.HD.ExtendedPublic.{
    Address,
    ChildFromIndex,
    ChildFromDerivationPath,
    Serialization,
    Deserialization
  }

  alias BitcoinLib.Key.HD.{DerivationPath, ExtendedPrivate, ExtendedPublic, Fingerprint}

  @doc """
  Derives an extended public key from an extended private key. Happens to be the same process
  as for regular keys.

  Inspired by https://learnmeabitcoin.com/technical/hd-wallets#master-private-key

  ## Examples
    iex> %BitcoinLib.Key.HD.ExtendedPrivate{
    ...>   key: <<0x081549973BAFBBA825B31BCC402A3C4ED8E3185C2F3A31C75E55F423E9629AA3::264>>,
    ...>   chain_code: <<0x1D7D2A4C940BE028B945302AD79DD2CE2AFE5ED55E1A2937A5AF57F8401E73DD::256>>
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.from_private_key()
    %BitcoinLib.Key.HD.ExtendedPublic{
      fingerprint: <<0xED104CB8::32>>,
      key: <<0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC::264>>,
      chain_code: <<0x1D7D2A4C940BE028B945302AD79DD2CE2AFE5ED55E1A2937A5AF57F8401E73DD::256>>,
      depth: 0,
      index: 0,
      parent_fingerprint: <<0::32>>
    }
  """
  @spec from_private_key(%ExtendedPrivate{}) :: {integer(), integer()}
  def from_private_key(%ExtendedPrivate{} = private_key) do
    {_, compressed} =
      private_key.key
      |> BitcoinLib.Key.Public.from_private_key()

    %ExtendedPublic{
      key: compressed,
      chain_code: private_key.chain_code,
      depth: private_key.depth,
      index: private_key.index,
      parent_fingerprint: private_key.parent_fingerprint
    }
    |> add_fingerprint()
  end

  @doc """
  Converts the public key to an address of the type specified as the second parameter

  Defaults to bech32 address type

  ## Examples
    iex> %BitcoinLib.Key.HD.ExtendedPublic{
    ...>   key: <<0x3EB181FB7B5CF63D82307188B20828B83008F2D2511E5C6EDCBE171C63DD2CBC1::264>>,
    ...>   chain_code: <<0x581F15490635CF8CD0AEEF556562F52C60179E0E87E0EA92977E364D949DC2E4::256>>,
    ...>   depth: 0x5,
    ...>   index: 0x0
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.to_address(:p2pkh)
    "1BRjWnoAVg3EASJHex5YeyDWC1zZ4CA5vc"
  """
  @spec to_address(%ExtendedPublic{}, :p2pkh | :p2sh | :bech32) :: binary()
  def to_address(%ExtendedPublic{} = public_key, type \\ :bech32, network \\ :mainnet) do
    public_key
    |> Address.from_extended_public_key(type, network)
  end

  @doc """
  Serialization of a master public key into its xpub version

  ## Examples
    values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

    iex> %BitcoinLib.Key.HD.ExtendedPublic{
    ...>   key: <<0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2::264>>,
    ...>   chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>,
    ...>   depth: 0,
    ...>   index: 0,
    ...>   parent_fingerprint: <<0::32>>
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.serialize()
    {
      :ok,
      "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
    }
  """
  @spec serialize(%ExtendedPublic{}, :xpub | :ypub | :zpub) ::
          {:ok, binary()} | {:error, binary()}
  def serialize(public_key, format \\ :xpub) do
    Serialization.serialize(public_key, format)
  end

  @doc """
  Serialization of a master public key into its xpub version

  ## Examples
    values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

    iex> %BitcoinLib.Key.HD.ExtendedPublic{
    ...>   key: <<0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2::264>>,
    ...>   chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>,
    ...>   depth: 0,
    ...>   index: 0,
    ...>   parent_fingerprint: <<0::32>>
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.serialize!()
    "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
  """
  @spec serialize(%ExtendedPublic{}, :xpub | :ypub) :: binary()
  def serialize!(public_key, format \\ :xpub) do
    {:ok, serialized} = serialize(public_key, format)

    serialized
  end

  @doc """
  Deserialization of a public key from its xpub version

  ## Examples
    values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

    iex> "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.deserialize()
    {
      :ok,
      %BitcoinLib.Key.HD.ExtendedPublic{
        fingerprint: <<0x3442193E::32>>,
        key: <<0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2::264>>,
        chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>,
        depth: 0,
        index: 0,
        parent_fingerprint: <<0::32>>
      }
    }
  """
  @spec deserialize(binary()) :: {:ok, %ExtendedPublic{}} | {:error, binary()}
  def deserialize(serialized_public_key) do
    case Deserialization.deserialize(serialized_public_key) do
      {:ok, public_key} -> {:ok, public_key |> add_fingerprint()}
      {:error, _} = result -> result
    end
  end

  @doc """
  Deserialization of a public key from its xpub version

  ## Examples
    values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

    iex> "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.deserialize!()
    %BitcoinLib.Key.HD.ExtendedPublic{
      fingerprint: <<0x3442193E::32>>,
      key: <<0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2::264>>,
      chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>,
      depth: 0,
      index: 0,
      parent_fingerprint: <<0::32>>
    }
  """
  @spec deserialize!(binary()) :: %ExtendedPublic{}
  def deserialize!(serialized_public_key) do
    {:ok, public_key} = deserialize(serialized_public_key)

    public_key
  end

  @doc """
  Derives the nth child of a HD public key

  Takes a public key, its chain code and the child's index
  Returns the child's public key and it's associated chain code

  Inspired by https://learnmeabitcoin.com/technical/extended-keys#child-extended-key-derivation

  ## Examples
    iex> public_key = %BitcoinLib.Key.HD.ExtendedPublic{
    ...>  key: <<0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9::264>>,
    ...>  chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    ...> }
    ...> index = 0
    ...> BitcoinLib.Key.HD.ExtendedPublic.derive_child(public_key, index)
    {
      :ok,
      %BitcoinLib.Key.HD.ExtendedPublic{
        key: <<0x30204D3503024160E8303C0042930EA92A9D671DE9AA139C1867353F6B6664E59::264>>,
        chain_code: <<0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31::256>>,
        depth: 1,
        index: 0,
        parent_fingerprint: <<0x18C1259::32>>,
        fingerprint: <<0x9680603F::32>>
      }
    }
  """
  @spec derive_child(%ExtendedPublic{}, binary()) :: {:ok, %ExtendedPublic{}}
  def derive_child(public_key, index) do
    ChildFromIndex.get(public_key, index)
  end

  @doc """
  Simply calls from_derivation_path and directly returns the public key whatever the outcome.any()
  Will crash if the index is negative or greater than 0x7FFFFFFF

  ## Examples
    iex> public_key = %BitcoinLib.Key.HD.ExtendedPublic{
    ...>  key: <<0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9::264>>,
    ...>  chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    ...> }
    ...> index = 0
    ...> BitcoinLib.Key.HD.ExtendedPublic.derive_child!(public_key, index)
    %BitcoinLib.Key.HD.ExtendedPublic{
      key: <<0x30204D3503024160E8303C0042930EA92A9D671DE9AA139C1867353F6B6664E59::264>>,
      chain_code: <<0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31::256>>,
      depth: 1,
      index: 0,
      parent_fingerprint: <<0x18C1259::32>>,
      fingerprint: <<0x9680603F::32>>
    }
  """
  @spec derive_child!(%ExtendedPublic{}, integer()) :: %ExtendedPublic{}
  def derive_child!(public_key, index) do
    derive_child(public_key, index)
    |> elem(1)
  end

  @doc """
  Derives a child public key, following a derivation path

  ## Examples
    iex> public_key = %BitcoinLib.Key.HD.ExtendedPublic{
    ...>   key: <<0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9::264>>,
    ...>   chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    ...> }
    ...> {:ok, derivation_path} = BitcoinLib.Key.HD.DerivationPath.parse("M/44'/0'/0'/0/0")
    ...> BitcoinLib.Key.HD.ExtendedPublic.from_derivation_path(public_key, derivation_path)
    {
      :ok,
      %BitcoinLib.Key.HD.ExtendedPublic{
        key: <<0x29DCAFD0D7D67B13657CC9EE7C8976E141F20F0684BF3FC83CAF068E74186BCDC::264>>,
        chain_code: <<0x162EEE68F7C3823CAF8BD2615A4A33633673CAAB66FF6F338FB0653FC59D462D::256>>,
        depth: 5,
        index: 0,
        parent_fingerprint: <<0xCA2A5281::32>>,
        fingerprint: <<0xAEAAB1AD::32>>
      }
    }
  """
  @spec from_derivation_path(%ExtendedPublic{}, %DerivationPath{}) :: {:ok, %ExtendedPublic{}}
  def from_derivation_path(%ExtendedPublic{} = public_key, %DerivationPath{} = derivation_path) do
    ChildFromDerivationPath.get(public_key, derivation_path)
  end

  @doc """
  Computes a public key hash out of a public key

  ## Examples
    iex> %BitcoinLib.Key.HD.ExtendedPublic{
    ...>   key: <<0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC::264>>,
    ...>   chain_code: <<0x1D7D2A4C940BE028B945302AD79DD2CE2AFE5ED55E1A2937A5AF57F8401E73DD::256>>
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.get_hash()
    <<0xED104CB8EF3ADABEC5D2BE8178C99847F9694269::160>>
  """
  def get_hash(%ExtendedPublic{} = public_key) do
    BitcoinLib.Key.PublicHash.from_public_key(public_key.key)
  end

  defp add_fingerprint(%ExtendedPublic{} = public_key) do
    public_key
    |> Map.put(:fingerprint, Fingerprint.compute(public_key))
  end
end
