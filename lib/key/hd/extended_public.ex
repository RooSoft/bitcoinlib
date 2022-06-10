defmodule BitcoinLib.Key.HD.ExtendedPublic do
  @moduledoc """
  Bitcoin extended public key management module
  """

  @doc """
  Derives an extended public key from an extended private key. Happens to be the same process
  as for regular keys.

  ## Examples
    iex> "081549973bafbba825b31bcc402a3c4ed8e3185c2f3a31c75e55f423e9629aa3"
    ...> |> BitcoinLib.Key.HD.ExtendedPublic.from_private_key()
    {
      "0443b337dec65a47b3362c9620a6e6ff39a1ddfa908abab1666c8a30a3f8a7ccccfc24a7914950b6405729a9313cec6ae5bb4a082f92d05ac49df4b6dd8387bfeb",
      "0343b337dec65a47b3362c9620a6e6ff39a1ddfa908abab1666c8a30a3f8a7cccc"
    }
  """
  def from_private_key(private_key) do
    private_key
    |> BitcoinLib.Key.Public.from_private_key()
  end
end
