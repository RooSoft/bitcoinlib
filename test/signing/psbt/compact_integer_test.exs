defmodule BitcoinLib.Signing.Psbt.CompactIntegerTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Signing.Psbt.CompactInteger

  alias BitcoinLib.Signing.Psbt.CompactInteger

  test "encode a 8 bits integer in the compact form" do
    encoded = CompactInteger.encode(0xAB)

    assert <<0xAB>> = encoded
  end

  test "encode a 16 bits integer in the compact little endian form" do
    encoded = CompactInteger.encode(0xFED)

    assert <<0xFDED0F::24>> = encoded
  end

  test "encode a 32 bits integer in the compact little endian form" do
    encoded = CompactInteger.encode(0xFEDCB)

    assert <<0xFECBED0F00::40>> = encoded
  end

  test "encode a 64 bits integer in the compact little endian form" do
    encoded = CompactInteger.encode(0xFEDCBA987)

    assert <<0xFF87A9CBED0F000000::72>> = encoded
  end

  test "encode a 16 bits integer in the compact big endian form" do
    encoded = CompactInteger.encode(0xFED, :big_endian)

    assert <<0xFD0FED::24>> = encoded
  end

  test "encode a 32 bits integer in the compact big endian form" do
    encoded = CompactInteger.encode(0xFEDCB, :big_endian)

    assert <<0xFE000FEDCB::40>> = encoded
  end

  test "encode a 64 bits integer in the compact big endian form" do
    encoded = CompactInteger.encode(0xFEDCBA987, :big_endian)

    assert <<0xFF0000000FEDCBA987::72>> = encoded
  end

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

    assert %CompactInteger{value: 0x201, size: 16, remaining: <<>>} == compact_integer
  end

  test "parse a 32 bits compact integer, with no rest" do
    data = <<0xFE, 1, 2, 3, 4>>

    compact_integer =
      data
      |> CompactInteger.extract_from()

    assert %CompactInteger{value: 0x4030201, size: 32, remaining: <<>>} == compact_integer
  end

  test "parse a 64 bits compact integer, with no rest" do
    data = <<0xFF, 1, 2, 3, 4, 5, 6, 7, 8>>

    compact_integer =
      data
      |> CompactInteger.extract_from()

    assert %CompactInteger{value: 0x807060504030201, size: 64, remaining: <<>>} == compact_integer
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

    assert %CompactInteger{value: 0x201, size: 16, remaining: <<1, 2, 3>>} == compact_integer
  end

  test "parse a 32 bits compact integer, with something remaining" do
    data = <<0xFE, 1, 2, 3, 4, 1, 2, 3>>

    compact_integer =
      data
      |> CompactInteger.extract_from()

    assert %CompactInteger{value: 0x4030201, size: 32, remaining: <<1, 2, 3>>} == compact_integer
  end

  test "parse a 64 bits compact integer, with something remaining" do
    data = <<0xFF, 1, 2, 3, 4, 5, 6, 7, 8, 2, 1>>

    compact_integer =
      data
      |> CompactInteger.extract_from()

    assert %CompactInteger{value: 0x807060504030201, size: 64, remaining: <<2, 1>>} ==
             compact_integer
  end
end
