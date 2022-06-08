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
      |> Checksum.compute(4)

    assert 2 == checksum
  end

  test "validates a seed's checksum" do
    binary =
      2_014_322_176_579_569_124_086_586_186_155_219_417_123
      |> Binary.from_integer()

    is_valid? =
      binary
      |> BitcoinLib.Key.MnemonicSeed.Checksum.validate_seed(4)

    assert is_valid?
  end
end
