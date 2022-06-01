defmodule BitcoinLib.CryptoTest do
  use ExUnit.Case

  alias BitcoinLib.Crypto

  test "creates a SHA256 hash from a string" do
    # based on https://passwordsgenerator.net/sha256-hash-generator/
    value = "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"

    hash =
      value
      |> Crypto.sha256()

    assert hash == "AB6A8F1D9E2B0333DFF8E370ED6FDFE20B2E8008E045EFB3FB3298C22F7569DA"
  end

  test "creates a RIPEMD160 hash from a string" do
    # based on https://md5calc.com/hash/ripemd160
    value = "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"

    hash =
      value
      |> Crypto.ripemd160()

    assert hash == "F23D97252131C60666708E4AE2C59FED1349F439"
  end

  test "creates a checksum" do
    value = "806c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a590737610701"

    checksum =
      value
      |> Crypto.checksum()

    assert checksum == "B56C36B1"
  end
end
