defmodule BitcoinLib.Key.MnemonicSeed.WordlistTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.MnemonicSeed.Wordlist

  alias BitcoinLib.Key.MnemonicSeed.Wordlist

  test "convert a 128 bit seed into a 12 words list" do
    seed = 133_578_906_290_548_567_715_753_216_948_162_927_473

    wordlist =
      seed
      |> Wordlist.convert_seed()

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
      |> Wordlist.convert_seed()

    assert wordlist ==
             String.split(
               "brick giggle panic mammal document foam gym canvas wheel among room analyst"
             )
  end
end
