defmodule BitcoinLib.Key.HD.ExtendedPublic.Serialization do
  @bip32_mainnet_version_bytes 0x0488B21E
  @bip49_mainnet_version_bytes 0x049D7CB2

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.ExtendedPublic

  @doc """
  Serialization of a master public key into an exportable version

  ## Examples
    values from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1

    iex> %BitcoinLib.Key.HD.ExtendedPublic{
    ...>   key: 0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2,
    ...>   chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508,
    ...>   depth: 0,
    ...>   index: 0,
    ...>   parent_fingerprint: 0
    ...> }
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.Serialization.serialize()
    {
      :ok,
      "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
    }
  """
  @spec serialize(%ExtendedPublic{}, Atom.t()) :: {:ok, String.t()}
  def serialize(%ExtendedPublic{} = pub_key, :xpub) do
    {:ok, execute(pub_key, @bip32_mainnet_version_bytes)}
  end

  @spec serialize(%ExtendedPublic{}, Atom.t()) :: {:ok, String.t()}
  def serialize(%ExtendedPublic{} = pub_key, :ypub) do
    {:ok, execute(pub_key, @bip49_mainnet_version_bytes)}
  end

  @spec serialize(%ExtendedPublic{}, Atom.t()) :: {:error, String.t()}
  def serialize(%ExtendedPublic{}, _) do
    {:error, "unknown serialization format"}
  end

  @spec execute(%ExtendedPublic{}, String.t()) :: String.t()
  defp execute(
         %ExtendedPublic{
           key: key,
           depth: depth,
           index: index,
           parent_fingerprint: parent_fingerprint,
           chain_code: chain_code
         },
         version_bytes
       ) do
    data = <<
      version_bytes::size(32),
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
end
