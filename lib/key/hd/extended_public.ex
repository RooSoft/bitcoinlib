defmodule BitcoinLib.Key.HD.ExtendedPublic do
  @moduledoc """
  Bitcoin extended public key management module
  """

  @enforce_keys [:key, :chain_code]
  defstruct [:key, :chain_code, depth: 0, index: 0, parent_fingerprint: ""]

  @version_bytes 0x0488B21E

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.{ExtendedPrivate, ExtendedPublic}

  @doc """
  Derives an extended public key from an extended private key. Happens to be the same process
  as for regular keys.

  ## Examples
    iex> %BitcoinLib.Key.HD.ExtendedPrivate{
    ...>   key: 0x081549973bafbba825b31bcc402a3c4ed8e3185c2f3a31c75e55f423e9629aa3,
    ...>   chain_code: 0
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.from_private_key()
    %BitcoinLib.Key.HD.ExtendedPublic{
      key: 0x0343b337dec65a47b3362c9620a6e6ff39a1ddfa908abab1666c8a30a3f8a7cccc,
      chain_code: 0,
      depth: 0,
      index: 0,
      parent_fingerprint: ""
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
    ...>   chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.serialize_master_public_key()
    "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
  """
  @spec serialize_master_public_key(%ExtendedPublic{}) :: String.t()
  def serialize_master_public_key(public_key) do
    data = <<
      @version_bytes::size(32),
      0::size(8),
      0::size(32),
      0::size(32),
      public_key.chain_code::size(256),
      public_key.key::size(264)
    >>

    <<
      data::bitstring,
      Crypto.checksum_bitstring(data)::bitstring
    >>
    |> Base58.encode()
  end
end
