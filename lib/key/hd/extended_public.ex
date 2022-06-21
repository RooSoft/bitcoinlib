defmodule BitcoinLib.Key.HD.ExtendedPublic do
  @moduledoc """
  Bitcoin extended public key management module
  """

  @enforce_keys [:key, :chain_code]
  defstruct [:key, :chain_code, depth: 0, index: 0, parent_fingerprint: 0]

  @version_bytes 0x0488B21E

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.{ExtendedPrivate, ExtendedPublic}

  @doc """
  Derives an extended public key from an extended private key. Happens to be the same process
  as for regular keys.

  Inspired by https://learnmeabitcoin.com/technical/hd-wallets#master-private-key

  ## Examples
    iex> %BitcoinLib.Key.HD.ExtendedPrivate{
    ...>   key: 0x081549973BAFBBA825B31BCC402A3C4ED8E3185C2F3A31C75E55F423E9629AA3,
    ...>   chain_code: 0x1D7D2A4C940BE028B945302AD79DD2CE2AFE5ED55E1A2937A5AF57F8401E73DD
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.from_private_key()
    %BitcoinLib.Key.HD.ExtendedPublic{
      key: 0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC,
      chain_code: 0x1D7D2A4C940BE028B945302AD79DD2CE2AFE5ED55E1A2937A5AF57F8401E73DD,
      depth: 0,
      index: 0,
      parent_fingerprint: 0
    }
  """
  @spec from_private_key(%ExtendedPrivate{}) :: {Integer.t(), Integer.t()}
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
  end

  @doc """
  Serialization of a master public key into its xpub version

  ## Examples
    values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

    iex> %BitcoinLib.Key.HD.ExtendedPublic{
    ...>   key: 0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2,
    ...>   chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508,
    ...>   depth: 0,
    ...>   index: 0,
    ...>   parent_fingerprint: 0
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.serialize()
    "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
  """
  @spec serialize(%ExtendedPublic{}) :: String.t()
  def serialize(%ExtendedPublic{
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
      key::size(264)
    >>

    <<
      data::bitstring,
      Crypto.checksum_bitstring(data)::bitstring
    >>
    |> Base58.encode()
  end

  @doc """
  Deserialization of a public key from its xpub version

  ## Examples
    values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

    iex> "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.deserialize()
    %BitcoinLib.Key.HD.ExtendedPublic{
      key: 0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2,
      chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508,
      depth: 0,
      index: 0,
      parent_fingerprint: 0
    }
  """
  def deserialize(serialized_public_key) do
    <<
      @version_bytes::size(32),
      depth::size(8),
      parent_fingerprint::size(32),
      index::size(32),
      chain_code::size(256),
      key::size(264),
      _checksum::size(32)
    >> =
      serialized_public_key
      |> Base58.decode()

    %ExtendedPublic{
      key: key,
      chain_code: chain_code,
      depth: depth,
      index: index,
      parent_fingerprint: parent_fingerprint
    }
  end

  def get_hash(%ExtendedPublic{} = public_key) do
    BitcoinLib.Key.PublicHash.from_public_key(public_key.key)
  end
end
