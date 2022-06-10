defmodule BitcoinLib.Key.HD.ExtendedPublicTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.HD.ExtendedPublic

  alias BitcoinLib.Key.HD.ExtendedPublic

  test "derives an extended public key from an extended private key" do
    private_key = "081549973bafbba825b31bcc402a3c4ed8e3185c2f3a31c75e55f423e9629aa3"

    {uncompressed, compressed} =
      private_key
      |> ExtendedPublic.from_private_key()

    assert "0343b337dec65a47b3362c9620a6e6ff39a1ddfa908abab1666c8a30a3f8a7cccc" == compressed

    assert "0443b337dec65a47b3362c9620a6e6ff39a1ddfa908abab1666c8a30a3f8a7cccc" <>
             "fc24a7914950b6405729a9313cec6ae5bb4a082f92d05ac49df4b6dd8387bfeb" == uncompressed
  end
end
