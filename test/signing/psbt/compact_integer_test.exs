defmodule BitcoinLib.Signing.Psbt.CompactIntegerTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Signing.Psbt.CompactInteger

  alias BitcoinLib.Signing.Psbt.CompactInteger

  test "parse a 8 bits compact integer, with no rest" do
    data = <<2>>

    compact_integer =
      data
      |> CompactInteger.extract_from()

    assert %CompactInteger{value: 2, size: 8, remaining: <<>>} == compact_integer
  end

  test "parse a 16 bits compact integer, with no rest" do
    data = <<0xFD, 1, 2>>

    compact_integer =
      data
      |> CompactInteger.extract_from()

    assert %CompactInteger{value: 0x102, size: 16, remaining: <<>>} == compact_integer
  end

  test "parse a 32 bits compact integer, with no rest" do
    data = <<0xFE, 1, 2, 3, 4>>

    compact_integer =
      data
      |> CompactInteger.extract_from()

    assert %CompactInteger{value: 0x1020304, size: 32, remaining: <<>>} == compact_integer
  end

  test "parse a 64 bits compact integer, with no rest" do
    data = <<0xFF, 1, 2, 3, 4, 5, 6, 7, 8>>

    compact_integer=
      data
      |> CompactInteger.extract_from()

    assert %CompactInteger{value: 0x102030405060708, size: 64, remaining: <<>>} == compact_integer
  end

  test "parse a 8 bits compact integer, with something remaining" do
    data = <<2, 3, 4>>

    compact_integer =
      data
      |> CompactInteger.extract_from()

    assert %CompactInteger{value: 2, size: 8, remaining: <<3, 4>>} == compact_integer
  end


  test "parse a 16 bits compact integer, with something remaining" do
    data = <<0xFD, 1, 2, 1, 2, 3>>

    compact_integer =
      data
      |> CompactInteger.extract_from()

    assert %CompactInteger{value: 0x102, size: 16, remaining: <<1, 2, 3>>} == compact_integer
  end

  test "parse a 32 bits compact integer, with something remaining" do
    data = <<0xFE, 1, 2, 3, 4, 1, 2, 3>>

    compact_integer =
      data
      |> CompactInteger.extract_from()

    assert %CompactInteger{value: 0x1020304, size: 32, remaining: <<1, 2, 3>>} == compact_integer
  end

  test "parse a 64 bits compact integer, with something remaining" do
    data = <<0xFF, 1, 2, 3, 4, 5, 6, 7, 8, 2, 1>>

    compact_integer =
      data
      |> CompactInteger.extract_from()

    assert %CompactInteger{value: 0x102030405060708, size: 64, remaining: <<2, 1>>} == compact_integer
  end
end
