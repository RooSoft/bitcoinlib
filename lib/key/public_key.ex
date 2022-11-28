defmodule BitcoinLib.Key.PublicKey do
  @moduledoc """
  Bitcoin extended public key management module
  """

  require Integer

  @enforce_keys [:key]
  defstruct [
    :key,
    :uncompressed_key,
    :chain_code,
    depth: 0,
    index: 0,
    parent_fingerprint: <<0::32>>,
    fingerprint: <<0::32>>
  ]

  alias BitcoinLib.Key.PublicKey.{
    ChildFromIndex,
    ChildFromDerivationPath,
    Serialization,
    Deserialization
  }

  alias BitcoinLib.{Address, Crypto}
  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Key.HD.{DerivationPath, Fingerprint}

  @doc """
  Derives an extended public key from an extended private key. Happens to be the same process
  as for regular keys.

  Inspired by https://learnmeabitcoin.com/technical/hd-wallets#master-private-key

  ## Examples
      iex> %BitcoinLib.Key.PrivateKey{
      ...>   key: <<0x081549973BAFBBA825B31BCC402A3C4ED8E3185C2F3A31C75E55F423E9629AA3::264>>,
      ...>   chain_code: <<0x1D7D2A4C940BE028B945302AD79DD2CE2AFE5ED55E1A2937A5AF57F8401E73DD::256>>
      ...> }
      ...> |> BitcoinLib.Key.PublicKey.from_private_key()
      %BitcoinLib.Key.PublicKey{
        fingerprint: <<0xED104CB8::32>>,
        key: <<0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC::264>>,
        uncompressed_key: <<0x0443b337dec65a47b3362c9620a6e6ff39a1ddfa908abab1666c8a30a3f8a7ccccfc24a7914950b6405729a9313cec6ae5bb4a082f92d05ac49df4b6dd8387bfeb::520>>,
        chain_code: <<0x1D7D2A4C940BE028B945302AD79DD2CE2AFE5ED55E1A2937A5AF57F8401E73DD::256>>,
        depth: 0,
        index: 0,
        parent_fingerprint: <<0::32>>
      }
  """
  @spec from_private_key(%PrivateKey{}) :: %PublicKey{}
  def from_private_key(%PrivateKey{} = private_key) do
    {uncompressed, compressed} =
      private_key.key
      |> extract_from_private_key()

    %PublicKey{
      key: compressed,
      uncompressed_key: uncompressed,
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
      iex> %BitcoinLib.Key.PublicKey{
      ...>   key: <<0x3EB181FB7B5CF63D82307188B20828B83008F2D2511E5C6EDCBE171C63DD2CBC1::264>>,
      ...>   chain_code: <<0x581F15490635CF8CD0AEEF556562F52C60179E0E87E0EA92977E364D949DC2E4::256>>,
      ...>   depth: 0x5,
      ...>   index: 0x0
      ...> }
      ...> |> BitcoinLib.Key.PublicKey.to_address(:p2pkh)
      "1BRjWnoAVg3EASJHex5YeyDWC1zZ4CA5vc"
  """
  @spec to_address(%PublicKey{}, :p2pkh | :p2sh | :p2wpkh) :: binary()
  def to_address(%PublicKey{} = public_key, type \\ :p2wpkh, network \\ :mainnet) do
    public_key
    |> Address.from_public_key(type, network)
  end

  @doc """
  Creates a public key hash

  ## Examples
      iex> %BitcoinLib.Key.PublicKey{
      ...>   key: <<0x02b4632d08485ff1df2db55b9dafd23347d1c47a457072a1e87be26896549a8737::264>>
      ...> }
      ...> |> BitcoinLib.Key.PublicKey.hash()
      <<0x93ce48570b55c42c2af816aeaba06cfee1224fae::160>>
  """
  @spec hash(%PublicKey{}) :: <<_::160>>
  def hash(%PublicKey{key: key}) do
    Crypto.hash160(key)
  end

  @doc """
  Serialization of a master public key into its xpub version

  values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

  ## Examples
      iex> %BitcoinLib.Key.PublicKey{
      ...>   key: <<0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2::264>>,
      ...>   chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>,
      ...>   depth: 0,
      ...>   index: 0,
      ...>   parent_fingerprint: <<0::32>>
      ...> }
      ...> |> BitcoinLib.Key.PublicKey.serialize()
      {
        :ok,
        "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
      }
  """
  @spec serialize(%PublicKey{}, :mainnet | :testnet, :bip32 | :bip49 | :bip84) ::
          {:ok, binary()} | {:error, binary()}
  def serialize(public_key, network \\ :mainnet, format \\ :bip32) do
    Serialization.serialize(public_key, network, format)
  end

  @doc """
  Serialization of a master public key into its xpub version

  values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

  ## Examples
      iex> %BitcoinLib.Key.PublicKey{
      ...>   key: <<0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2::264>>,
      ...>   chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>,
      ...>   depth: 0,
      ...>   index: 0,
      ...>   parent_fingerprint: <<0::32>>
      ...> }
      ...> |> BitcoinLib.Key.PublicKey.serialize!()
      "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
  """
  @spec serialize!(%PublicKey{}, :mainnet | :testnet, :bip32 | :bip49 | :bip84) :: binary()
  def serialize!(public_key, network \\ :mainnet, format \\ :bip32) do
    case serialize(public_key, network, format) do
      {:ok, serialized} -> serialized
      {:error, message} -> raise message
    end
  end

  @doc """
  Deserialization of a public key from its xpub version

  values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

  ## Examples
      iex> "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
      ...> |> BitcoinLib.Key.PublicKey.deserialize()
      {
        :ok,
        %BitcoinLib.Key.PublicKey{
          fingerprint: <<0x3442193E::32>>,
          key: <<0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2::264>>,
          chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>,
          depth: 0,
          index: 0,
          parent_fingerprint: <<0::32>>
        },
        :mainnet,
        :bip32
      }
  """
  @spec deserialize(binary()) ::
          {:ok, %PublicKey{}, :mainnet | :testnet, :bip32 | :bip49 | :bip84}
          | {:error, String.t()}
  def deserialize(serialized_public_key) do
    case Deserialization.deserialize(serialized_public_key) do
      {:ok, public_key, network, format} ->
        {:ok, public_key |> add_fingerprint(), network, format}

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Deserialization of a public key from its xpub version

  values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

  ## Examples
      iex> "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
      ...> |> BitcoinLib.Key.PublicKey.deserialize!()
      %BitcoinLib.Key.PublicKey{
        fingerprint: <<0x3442193E::32>>,
        key: <<0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2::264>>,
        chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>,
        depth: 0,
        index: 0,
        parent_fingerprint: <<0::32>>
      }
  """
  @spec deserialize!(binary()) :: %PublicKey{}
  def deserialize!(serialized_public_key) do
    with {:ok, public_key, _network, _format} <- deserialize(serialized_public_key) do
      public_key
    else
      {:error, message} -> raise message
    end
  end

  @doc """
  Derives the nth child of a HD public key

  Takes a public key, its chain code and the child's index
  Returns the child's public key and it's associated chain code

  Inspired by https://learnmeabitcoin.com/technical/extended-keys#child-extended-key-derivation

  ## Examples
      iex> public_key = %BitcoinLib.Key.PublicKey{
      ...>  key: <<0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9::264>>,
      ...>  chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
      ...> }
      ...> index = 0
      ...> BitcoinLib.Key.PublicKey.derive_child(public_key, index)
      {
        :ok,
        %BitcoinLib.Key.PublicKey{
          key: <<0x30204D3503024160E8303C0042930EA92A9D671DE9AA139C1867353F6B6664E59::264>>,
          chain_code: <<0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31::256>>,
          depth: 1,
          index: 0,
          parent_fingerprint: <<0x18C1259::32>>,
          fingerprint: <<0x9680603F::32>>
        }
      }
  """
  @spec derive_child(%PublicKey{}, integer()) :: {:ok, %PublicKey{}} | {:error, binary()}
  def derive_child(public_key, index) do
    ChildFromIndex.get(public_key, index)
  end

  @doc """
  Simply calls from_derivation_path and directly returns the public key whatever the outcome.any()
  Will crash if the index is negative or greater than 0x7FFFFFFF

  ## Examples
      iex> public_key = %BitcoinLib.Key.PublicKey{
      ...>  key: <<0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9::264>>,
      ...>  chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
      ...> }
      ...> index = 0
      ...> BitcoinLib.Key.PublicKey.derive_child!(public_key, index)
      %BitcoinLib.Key.PublicKey{
        key: <<0x30204D3503024160E8303C0042930EA92A9D671DE9AA139C1867353F6B6664E59::264>>,
        chain_code: <<0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31::256>>,
        depth: 1,
        index: 0,
        parent_fingerprint: <<0x18C1259::32>>,
        fingerprint: <<0x9680603F::32>>
      }
  """
  @spec derive_child!(%PublicKey{}, integer()) :: %PublicKey{}
  def derive_child!(public_key, index) do
    derive_child(public_key, index)
    |> elem(1)
  end

  @doc """
  Derives a child public key, following a derivation path

  ## Examples
      iex> public_key = %BitcoinLib.Key.PublicKey{
      ...>   key: <<0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9::264>>,
      ...>   chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
      ...> }
      ...> {:ok, derivation_path} = BitcoinLib.Key.HD.DerivationPath.parse("M/44'/0'/0'/0/0")
      ...> BitcoinLib.Key.PublicKey.from_derivation_path(public_key, derivation_path)
      {
        :ok,
        %BitcoinLib.Key.PublicKey{
          key: <<0x29DCAFD0D7D67B13657CC9EE7C8976E141F20F0684BF3FC83CAF068E74186BCDC::264>>,
          chain_code: <<0x162EEE68F7C3823CAF8BD2615A4A33633673CAAB66FF6F338FB0653FC59D462D::256>>,
          depth: 5,
          index: 0,
          parent_fingerprint: <<0xCA2A5281::32>>,
          fingerprint: <<0xAEAAB1AD::32>>
        }
      }
  """
  @spec from_derivation_path(%PublicKey{}, %DerivationPath{}) :: {:ok, %PublicKey{}}
  def from_derivation_path(%PublicKey{} = public_key, %DerivationPath{} = derivation_path) do
    ChildFromDerivationPath.get(public_key, derivation_path)
  end

  @doc """
  Checks a signature against a public key

  ## Examples
      iex> message = <<0xf05750d5bd2c2b4bbbd57cb07082ba5aabb41863e33bf2cd187a9adb1443dbc3::256>>
      ...> public_key = %BitcoinLib.Key.PublicKey{
      ...>   key: <<0x03f0e5a53db9f85e5b2eecf677925ffe21dd1409bcfe9a0730404053599b0901e5::264>>
      ...> }
      ...> <<0x30440220032a1544f599bf29981851e826e8a6f7c036958ba3543cf9778a0756dfc425f6022067eec131c0d73825633c0fddce1abfb14bb26bc9e0d6e9d644a77361f74cb55c::560>>
      ...> |> BitcoinLib.Key.PublicKey.validate_signature(message, public_key)
      true
  """
  @spec validate_signature(bitstring(), bitstring(), %PublicKey{}) :: boolean()
  def validate_signature(signature, message, %PublicKey{} = public_key) do
    Crypto.Secp256k1.validate(signature, message, public_key)
  end

  @doc """
  Returns a compressed version of an uncompressed public key

  ## Examples
    iex> <<0x0411DB93E1DCDB8A016B49840F8C53BC1EB68A382E97B1482ECAD7B148A6909A5CB2E0EADDFB84CCF9744464F82E160BFA9B8B64F9D4C03F999B8643F656B412A3::520>>
    ...> |> BitcoinLib.Key.PublicKey.compress()
    <<0x0211db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5c::264>>
  """
  @spec compress(<<_::520>>) :: <<_::264>>
  def compress(<<prefix::8, x::bitstring-256, _::bitstring-256>>) do
    case Integer.is_even(prefix) do
      true -> <<2::8, x::bitstring-256>>
      false -> <<3::8, x::bitstring-256>>
    end
  end

  defp add_fingerprint(%PublicKey{} = public_key) do
    public_key
    |> Map.put(:fingerprint, Fingerprint.compute(public_key))
  end

  defp extract_from_private_key(private_key) when is_bitstring(private_key) do
    public_uncompressed = Crypto.secp256k1(private_key)

    compressed = get_compressed(public_uncompressed)

    {
      public_uncompressed,
      compressed
    }
  end

  defp get_compressed(public_uncompressed) do
    first_char =
      public_uncompressed
      |> get_first_char

    compressed_body =
      public_uncompressed
      |> Binary.part(1, 32)

    first_char <> compressed_body
  end

  defp get_first_char(public_uncompressed) do
    reminder =
      public_uncompressed
      |> Binary.last()
      |> rem(2)

    case reminder do
      0 -> <<2>>
      1 -> <<3>>
    end
  end
end

defimpl Inspect, for: BitcoinLib.Key.PublicKey do
  alias BitcoinLib.Formatting.HexBinary

  def inspect(%BitcoinLib.Key.PublicKey{} = public_key, opts) do
    %{
      public_key
      | key: %HexBinary{data: public_key.key},
        uncompressed_key:
          case public_key.uncompressed_key do
            nil -> nil
            _ -> %HexBinary{data: public_key.uncompressed_key}
          end,
        chain_code:
          case public_key.chain_code do
            nil -> nil
            _ -> %HexBinary{data: public_key.chain_code}
          end,
        fingerprint:
          case public_key.fingerprint do
            nil -> nil
            _ -> %HexBinary{data: public_key.fingerprint}
          end,
        parent_fingerprint:
          case public_key.parent_fingerprint do
            nil -> nil
            _ -> %HexBinary{data: public_key.parent_fingerprint}
          end
    }
    |> Inspect.Any.inspect(opts)
  end
end
