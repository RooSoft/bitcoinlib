defmodule BitcoinLib.Key.MnemonicSeedTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.MnemonicSeed

  alias BitcoinLib.Key.MnemonicSeed
  alias BitcoinLib.Key.MnemonicSeed.Wordlist

  test "convert a 128 bit seed into a 12 words list" do
    seed = 133_578_906_290_548_567_715_753_216_948_162_927_473

    wordlist =
      seed
      |> MnemonicSeed.from_integer()

    assert wordlist == [
             "good",
             "very",
             "casual",
             "truth",
             "rescue",
             "blade",
             "muffin",
             "pool",
             "hope",
             "cupboard",
             "man",
             "toddler"
           ]
  end

  test "convert another 128 bit seed into a 12 words list" do
    seed = 36_783_498_498_455_780_461_879_399_537_283_362_692

    wordlist =
      seed
      |> MnemonicSeed.from_integer()

    assert wordlist ==
             String.split(
               "brick giggle panic mammal document foam gym canvas wheel among room analyst"
             )
  end

  test "convert a 256 bit seed into a 24 words list" do
    seed =
      69_868_206_896_192_366_849_867_350_978_813_947_151_290_649_318_688_797_101_200_588_609_849_994_088_743

    wordlist =
      seed
      |> MnemonicSeed.from_integer()

    assert wordlist ==
             String.split(
               "omit scale diagram cart tray veteran love trial april minute salt actual term " <>
                 "concert guitar message umbrella animal grain gain mule decide duty trophy"
             )
  end
end
