defmodule BitcoinLib.CryptoTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Crypto

  alias BitcoinLib.Crypto

  test "creates a HMAC hash from a string" do
    # based on https://beautifytools.com/hmac-generator.php
    key = "Bitcoin seed"

    value =
      "b1680c7a6ea6ed5ac9bf3bc3b43869a4c77098e60195bae51a94159333820e125c3409b8c8d74b4489f28ce71b06799b1126c1d9620767c2dadf642cf787cf36"

    hash =
      value
      |> Crypto.hmac(key)

    assert hash ==
             "1f22e99440b621e47e74a779ce4063c497846ab118fa2531a49611d43dca5787" <>
               "ea2d0fb95937144c4fe3730b6e656895d0e30defa312b164727ca4cdd3530b43"
  end

  test "creates a checksum" do
    value = "806c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a590737610701"

    checksum =
      value
      |> Crypto.checksum()

    assert checksum == "b56c36b1"
  end

  test "makes a hash160 of a bitstring" do
    value = <<128, 0, 0, 44>>

    hash =
      value
      |> Crypto.hash160_bitstring()

    assert <<251, 126, 153, 20, 166, 224, 56, 154, 55, 180, 46, 3, 58, 245, 19, 162, 196, 12, 64,
             2>> ==
             hash
  end
end
