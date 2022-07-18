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
    data = <<0xFD, 1, 2>>

    {number, rest} =
      data
      |> CompactInteger.extract_from()

    assert 0x102 == number
    assert <<>> == rest
  end

  test "parse a 32 bits compact integer, with no rest" do
    data = <<0xFE, 1, 2, 3, 4>>

    {number, rest} =
      data
      |> CompactInteger.extract_from()

    assert 0x1020304 == number
    assert <<>> == rest
  end

  test "parse a 64 bits compact integer, with no rest" do
    data = <<0xFF, 1, 2, 3, 4, 5, 6, 7, 8>>

    {number, rest} =
      data
      |> CompactInteger.extract_from()

    assert 0x102030405060708 == number
    assert <<>> == rest
  end

  test "parse a 8 bits compact integer, with something remaining" do
    data = <<2, 3, 4>>

    {number, rest} =
      data
      |> CompactInteger.extract_from()

    assert 2 == number
    assert <<3, 4>> == rest
  end


  test "parse a 16 bits compact integer, with something remaining" do
    data = <<0xFD, 1, 2, 1, 2, 3>>

    {number, rest} =
      data
      |> CompactInteger.extract_from()

    assert 0x102 == number
    assert <<1, 2, 3>> == rest
  end


  test "parse a 32 bits compact integer, with something remaining" do
    data = <<0xFE, 1, 2, 3, 4, 1, 2, 3>>

    {number, rest} =
      data
      |> CompactInteger.extract_from()

    assert 0x1020304 == number
    assert <<1, 2, 3>> == rest
  end

  test "parse a 64 bits compact integer, with something remaining" do
    data = <<0xFF, 1, 2, 3, 4, 5, 6, 7, 8, 2, 1>>

    {number, rest} =
      data
      |> CompactInteger.extract_from()

    assert 0x102030405060708 == number
    assert <<2, 1>> == rest
  end
end
