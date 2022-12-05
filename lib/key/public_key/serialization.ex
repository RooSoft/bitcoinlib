defmodule BitcoinLib.Key.PublicKey.Serialization do
  @moduledoc """
  Extended public key serialization module

  To test the results, use https://www.npmjs.com/package/@swan-bitcoin/xpub-cli
  Serialization types: https://github.com/satoshilabs/slips/blob/master/slip-0132.md
  """

  @xpub_version_bytes 0x0488B21E
  @ypub_version_bytes 0x049D7CB2
  @zpub_version_bytes 0x04B24746

  @tpub_version_bytes 0x043587CF
  @upub_version_bytes 0x044A5262
  @vpub_version_bytes 0x045F1CF6

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.PublicKey

  @doc """
  Serialization of a master public key into an exportable version

  values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

  ## Examples
      iex> %BitcoinLib.Key.PublicKey{
      ...>   key: <<0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2::264>>,
      ...>   chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>,
      ...>   depth: 0,
      ...>   index: 0,
      ...>   parent_fingerprint: <<0::32>>
      ...> }
      ...> |> BitcoinLib.Key.PublicKey.Serialization.serialize(:mainnet, :bip32)
      {
        :ok,
        "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
      }
  """
  @spec serialize(PublicKey.t(), :mainnet | :testnet, :bip32 | :bip49 | :bip84) ::
          {:ok, binary()} | {:error, binary()}
  def serialize(%PublicKey{} = pub_key, :mainnet, :bip32) do
    {:ok, execute(pub_key, @xpub_version_bytes)}
  end

  def serialize(%PublicKey{} = pub_key, :mainnet, :bip49) do
    {:ok, execute(pub_key, @ypub_version_bytes)}
  end

  def serialize(%PublicKey{} = pub_key, :mainnet, :bip84) do
    {:ok, execute(pub_key, @zpub_version_bytes)}
  end

  def serialize(%PublicKey{} = pub_key, :testnet, :bip32) do
    {:ok, execute(pub_key, @tpub_version_bytes)}
  end

  def serialize(%PublicKey{} = pub_key, :testnet, :bip49) do
    {:ok, execute(pub_key, @upub_version_bytes)}
  end

  def serialize(%PublicKey{} = pub_key, :testnet, :bip84) do
    {:ok, execute(pub_key, @vpub_version_bytes)}
  end

  def serialize(%PublicKey{}, _, _) do
    {:error, "unknown serialization format"}
  end

  @spec execute(PublicKey.t(), integer()) :: binary()
  defp execute(
         %PublicKey{
           key: key,
           depth: depth,
           index: index,
           parent_fingerprint: parent_fingerprint,
           chain_code: chain_code
         },
         version_bytes
       ) do
    data = <<
      version_bytes::32,
      depth::8,
      parent_fingerprint::bitstring-32,
      index::32,
      chain_code::bitstring-256,
      key::bitstring-264
    >>

    <<
      data::bitstring,
      Crypto.checksum(data)::bitstring
    >>
    |> Base58.encode()
  end
end
