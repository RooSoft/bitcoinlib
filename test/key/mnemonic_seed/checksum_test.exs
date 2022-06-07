defmodule BitcoinLib.Key.MnemonicSeed.ChecksumTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.MnemonicSeed.Checksum

  alias BitcoinLib.Key.MnemonicSeed.Checksum

  test "compute a checksum" do
    binary =
      36_783_498_498_455_780_461_879_399_537_283_362_692
      |> Binary.from_integer()

    checksum =
      binary
      |> BitcoinLib.Key.MnemonicSeed.Checksum.compute(4)

    assert 2 == checksum
  end
end
