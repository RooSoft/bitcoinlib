defmodule BitcoinLib.Key.HD.ExtendedPublic.Deserialization do
  @bip32_mainnet_human_readable "xpub"
  @bip49_mainnet_human_readable "ypub"
  @bip84_mainnet_human_readable "zpub"

  alias BitcoinLib.Key.PublicKey

  @doc """
  Deserialization of a public key from its xpub version

  ## Examples
    values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

    iex> "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
    ...> |> BitcoinLib.Key.PublicKey.deserialize()
    %BitcoinLib.Key.PublicKey{
      key: 0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2,
      chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508,
      depth: 0,
      index: 0,
      parent_fingerprint: 0
    }
  """
  @spec deserialize(binary()) :: {:ok, %PublicKey{}}
  def deserialize(@bip32_mainnet_human_readable <> _data = serialized) do
    {:ok, execute(serialized)}
  end

  @spec deserialize(binary()) :: {:ok, %PublicKey{}}
  def deserialize(@bip49_mainnet_human_readable <> _data = serialized) do
    {:ok, execute(serialized)}
  end

  @spec deserialize(binary()) :: {:ok, %PublicKey{}}
  def deserialize(@bip84_mainnet_human_readable <> _data = serialized) do
    {:ok, execute(serialized)}
  end

  @spec deserialize(binary()) :: {:error, binary()}
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
