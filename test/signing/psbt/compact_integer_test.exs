defmodule BitcoinLib.Signing.Psbt.CompactIntegerTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Signing.Psbt.CompactInteger

  alias BitcoinLib.Signing.Psbt.CompactInteger

  test "parse a 8 bits compact integer, with no rest" do
    data = <<2>>

    {number, rest} =
      data
      |> CompactInteger.extract_from()

    assert 2 == number
    assert <<>> == rest
  end

  test "parse a 16 bits compact integer, with no rest" do
    data = <<0xFD, 0x1, 0x2>>

    {number, rest} =
      data
      |> CompactInteger.extract_from()

    assert 0x102 == number
    assert <<>> == rest
  end

  test "parse a 32 bits compact integer, with no rest" do
    data = <<0xFE, 0x1, 0x2, 0x3, 0x4>>

    {number, rest} =
      data
      |> CompactInteger.extract_from()

    assert 0x1020304 == number
    assert <<>> == rest
  end
end
