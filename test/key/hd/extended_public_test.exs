defmodule BitcoinLib.Key.HD.ExtendedPublicTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPublic

  alias BitcoinLib.Key.HD.ExtendedPublic

  test "derives an extended public key from an extended private key" do
    private_key = 0x081549973BAFBBA825B31BCC402A3C4ED8E3185C2F3A31C75E55F423E9629AA3

    {uncompressed, compressed} =
      private_key
      |> ExtendedPublic.from_private_key()

    assert 0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC == compressed

    assert 0x0443B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCCFC24A7914950B6405729A9313CEC6AE5BB4A082F92D05AC49DF4B6DD8387BFEB ==
             uncompressed
  end
end
