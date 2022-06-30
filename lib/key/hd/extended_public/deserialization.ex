defmodule BitcoinLib.Key.HD.ExtendedPublic.Deserialization do
  @bip32_mainnet_human_readable "xpub"
  @bip49_mainnet_human_readable "ypub"

  alias BitcoinLib.Key.HD.ExtendedPublic

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
  @spec deserialize(String.t()) :: {:ok, %ExtendedPublic{}}
  def deserialize(@bip32_mainnet_human_readable <> _data = serialized) do
    {:ok, execute(serialized)}
  end

  @spec deserialize(String.t()) :: {:ok, %ExtendedPublic{}}
  def deserialize(@bip49_mainnet_human_readable <> _data = serialized) do
    {:ok, execute(serialized)}
  end

  @spec deserialize(String.t()) :: {:error, String.t()}
  def deserialize(_) do
    {:error, "unknown pub key serialization format"}
  end

  defp execute(serialized_public_key) do
    <<
      _::size(32),
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
end
