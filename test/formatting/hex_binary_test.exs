defmodule BitcoinLib.Formatting.HexBinaryTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Formatting.HexBinary

  alias BitcoinLib.Formatting.HexBinary

  test "create a HexBinary from binary data" do
    binary = <<0x12345678::32>>

    hex_binary = HexBinary.from_binary(binary)

    assert %HexBinary{data: <<0x12345678::32>>} = hex_binary
  end

  test "display a hex binary" do
    hex_binary = HexBinary.from_binary(<<0x12345678::32>>)

    formatted = "#{inspect(hex_binary)}"

    assert "<<0x12345678::32>>" == formatted
  end
end
