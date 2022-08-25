defmodule BitcoinLib.Formatting.HexBinaryTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Formatting.HexBinary

  alias BitcoinLib.Formatting.HexBinary

  test "create a HexBinary from binary data" do
    binary = <<0x12345678::32>>

    hex_binary = HexBinary.from_binary(binary)

    assert %HexBinary{data: <<0x12345678::32>>} = hex_binary
  end
end
