defmodule BitcoinLib.CryptoTest do
  use ExUnit.Case

  doctest BitcoinLib.Crypto

  alias BitcoinLib.Crypto

  test "creates a SHA1 hash from a string" do
    # based on https://md5calc.com/hash/sha1
    value = "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"

    hash =
      value
      |> Crypto.sha1()

    assert hash == "4b68598994268b2dcb9560b5571eb244c2396139"
  end

  test "creates a double SHA256 hash from a string" do
    # based on https://www.webdevtutor.net/tools/online-hash-generator-sha256d
    value = "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"

    hash =
      value
      |> Crypto.double_sha256()

    assert hash == "de43342f6e8bcc34d95f36e4e1b8eab957a0ce2ff3b0e183142d91a871170f2b"
  end

  test "creates a SHA256 hash from a string" do
    # based on https://md5calc.com/hash/sha256
    value = "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"

    hash =
      value
      |> Crypto.sha256()

    assert hash == "ab6a8f1d9e2b0333dff8e370ed6fdfe20b2e8008e045efb3fb3298c22f7569da"
  end

  test "creates a RIPEMD160 hash from a string" do
    # based on https://md5calc.com/hash/ripemd160
    value = "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"

    hash =
      value
      |> Crypto.ripemd160()

    assert hash == "f23d97252131c60666708e4ae2c59fed1349f439"
  end

  test "creates a checksum" do
    value = "806c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a590737610701"

    checksum =
      value
      |> Crypto.checksum()

    assert checksum == "b56c36b1"
  end
end
