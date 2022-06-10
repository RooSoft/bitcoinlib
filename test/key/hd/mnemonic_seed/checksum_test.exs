defmodule BitcoinLib.Key.HD.MnemonicSeed.ChecksumTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.HD.MnemonicSeed.Checksum

  alias BitcoinLib.Key.HD.MnemonicSeed.Checksum

  test "compute a checksum" do
    checksum =
      <<27, 172, 62, 126, 195, 84, 6, 180, 26, 1, 13, 250, 0, 254, 239, 132>>
      |> Checksum.compute(4)

    assert 2 == checksum
  end

  test "validates a seed's checksum" do
    is_valid? =
      <<5, 235, 104, 86, 249, 249, 27, 246, 234, 99, 13, 18, 209, 116, 50, 248, 35>>
      |> Checksum.validate_seed()

    assert is_valid?
  end
end
