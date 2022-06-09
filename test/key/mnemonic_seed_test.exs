defmodule BitcoinLib.Key.MnemonicSeedTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.MnemonicSeed

  alias BitcoinLib.Key.MnemonicSeed

  test "convert a 128 bit entropy number into a 12 words list" do
    entropy = 101_750_443_022_601_924_635_824_320_539_097_414_732

    wordlist =
      entropy
      |> MnemonicSeed.wordlist_from_entropy()

    assert wordlist == [
             "erode",
             "gloom",
             "apart",
             "system",
             "broom",
             "lemon",
             "dismiss",
             "post",
             "artist",
             "slot",
             "humor",
             "occur"
           ]
  end

  test "convert another 128 bit entropy number into a 12 words list" do
    entropy = 36_783_498_498_455_780_461_879_399_537_283_362_692

    wordlist =
      entropy
      |> MnemonicSeed.wordlist_from_entropy()

    assert wordlist ==
             String.split(
               "brick giggle panic mammal document foam gym canvas wheel among room analyst"
             )
  end

  test "convert a 256 bit entropy number into a 24 words list" do
    entropy =
      69_868_206_896_192_366_849_867_350_978_813_947_151_290_649_318_688_797_101_200_588_609_849_994_088_743

    wordlist =
      entropy
      |> MnemonicSeed.wordlist_from_entropy()

    assert wordlist ==
             String.split(
               "omit scale diagram cart tray veteran love trial april minute salt actual term " <>
                 "concert guitar message umbrella animal grain gain mule decide duty trophy"
             )
  end
end
