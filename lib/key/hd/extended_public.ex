defmodule BitcoinLib.Key.HD.ExtendedPublic do
  @moduledoc """
  Bitcoin extended public key management module
  """

  @version_bytes 0x0488B21E

  alias BitcoinLib.Crypto

  @doc """
  Derives an extended public key from an extended private key. Happens to be the same process
  as for regular keys.

  ## Examples
    iex> 0x081549973bafbba825b31bcc402a3c4ed8e3185c2f3a31c75e55f423e9629aa3
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.from_private_key()
    {
      0x0443b337dec65a47b3362c9620a6e6ff39a1ddfa908abab1666c8a30a3f8a7ccccfc24a7914950b6405729a9313cec6ae5bb4a082f92d05ac49df4b6dd8387bfeb,
      0x0343b337dec65a47b3362c9620a6e6ff39a1ddfa908abab1666c8a30a3f8a7cccc
    }
  """
  @spec from_private_key(Integer.t()) :: {Integer.t(), Integer.t()}
  def from_private_key(private_key) do
    private_key
    |> BitcoinLib.Key.Public.from_private_key()
  end

  def serialize_master_public_key(key, chain_code) do
    data = <<
      @version_bytes::size(32),
      0::size(8),
      0::size(32),
      0::size(32),
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
