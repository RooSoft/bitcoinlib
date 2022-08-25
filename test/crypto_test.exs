defmodule BitcoinLib.CryptoTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Crypto

  alias BitcoinLib.Crypto

  test "creates a HMAC hash from a string" do
    # based on https://beautifytools.com/hmac-generator.php
    key = "Bitcoin seed"

    value =
      <<0xB1680C7A6EA6ED5AC9BF3BC3B43869A4C77098E60195BAE51A94159333820E125C3409B8C8D74B4489F28CE71B06799B1126C1D9620767C2DADF642CF787CF36::512>>

    hash =
      value
      |> Crypto.hmac(key)

    assert hash ==
             <<0x081549973BAFBBA825B31BCC402A3C4ED8E3185C2F3A31C75E55F423E9629AA31D7D2A4C940BE028B945302AD79DD2CE2AFE5ED55E1A2937A5AF57F8401E73DD::512>>
  end

  test "creates a checksum" do
    value = <<0x806C7AB2F961A1BC3F13CDC08DC41C3F439ADEBD549A8EF1C089E81A590737610701::272>>

    checksum =
      value
      |> Crypto.checksum_bitstring()

    assert checksum == <<0xB56C36B1::32>>
  end

  test "makes a hash160 of a bitstring" do
    value = <<128, 0, 0, 44>>

    hash =
      value
      |> Crypto.hash160()

    assert <<251, 126, 153, 20, 166, 224, 56, 154, 55, 180, 46, 3, 58, 245, 19, 162, 196, 12, 64,
             2>> ==
             hash
  end
end
