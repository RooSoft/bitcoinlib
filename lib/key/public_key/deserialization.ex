defmodule BitcoinLib.Key.PublicKey.Deserialization do
  @moduledoc """
  Extended public key deserialization module

  To test the results, use https://www.npmjs.com/package/@swan-bitcoin/xpub-cli
  Serialization types: https://github.com/satoshilabs/slips/blob/master/slip-0132.md
  """

  @bip32_mainnet_human_readable "xpub"
  @bip49_mainnet_human_readable "ypub"
  @bip84_mainnet_human_readable "zpub"

  @bip32_testnet_human_readable "tpub"
  @bip49_testnet_human_readable "upub"
  @bip84_testnet_human_readable "vpub"

  alias BitcoinLib.Key.PublicKey

  @doc """
  Deserialization of a public key from its xpub version

  values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

  ## Examples
      iex> "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
      ...> |> BitcoinLib.Key.PublicKey.deserialize()
      {
        :ok,
        %BitcoinLib.Key.PublicKey{
          key: <<0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2::264>>,
          chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>,
          depth: 0,
          index: 0,
          parent_fingerprint: <<0,0,0,0>>,
          fingerprint: <<0x3442193e::32>>
        },
        :mainnet,
        :bip32
      }
  """
  @spec deserialize(binary()) ::
          {
            :ok,
            PublicKey.t(),
            :mainnet | :testnet,
            :bip32 | :bip49 | :bip84
          }
          | {:error, binary()}
  def deserialize(@bip32_mainnet_human_readable <> _data = serialized) do
    {:ok, execute(serialized), :mainnet, :bip32}
  end

  def deserialize(@bip49_mainnet_human_readable <> _data = serialized) do
    {:ok, execute(serialized), :mainnet, :bip49}
  end

  def deserialize(@bip84_mainnet_human_readable <> _data = serialized) do
    {:ok, execute(serialized), :mainnet, :bip84}
  end

  def deserialize(@bip32_testnet_human_readable <> _data = serialized) do
    {:ok, execute(serialized), :testnet, :bip32}
  end

  def deserialize(@bip49_testnet_human_readable <> _data = serialized) do
    {:ok, execute(serialized), :testnet, :bip49}
  end

  def deserialize(@bip84_testnet_human_readable <> _data = serialized) do
    {:ok, execute(serialized), :testnet, :bip84}
  end

  def deserialize(_) do
    {:error, "unknown pub key serialization format"}
  end

  defp execute(serialized_public_key) do
    <<
      _::32,
      depth::8,
      parent_fingerprint::bitstring-32,
      index::32,
      chain_code::bitstring-256,
      key::bitstring-264,
      _checksum::32
    >> =
      serialized_public_key
      |> Base58.decode()

    %PublicKey{
      key: key,
      chain_code: chain_code,
      depth: depth,
      index: index,
      parent_fingerprint: parent_fingerprint
    }
  end
end
