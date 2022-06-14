defmodule BitcoinLib.Key.HD.MnemonicSeedTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.MnemonicSeed

  alias BitcoinLib.Key.HD.MnemonicSeed

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

  test "convert a 12 word mnemonic phrase into a seed" do
    mnemonic_phrase =
      "brick giggle panic mammal document foam gym canvas wheel among room analyst"

    seed =
      mnemonic_phrase
      |> MnemonicSeed.to_seed()

    assert 0x7E4803BD0278E223532F5833D81605BEDC5E16F39C49BDFFF322CA83D444892DDB091969761EA406BEE99D6AB613FAD6A99A6D4BEBA66897B252F00C9DD7B364 ==
             seed
  end

  test "convert a 24 word mnemonic phrase into a seed" do
    mnemonic_phrase =
      "work tenant tourist globe spice cattle suggest fever begin boil undo slogan " <>
        "concert mystery midnight affair frequent helmet federal token fit speak health vendor"

    seed =
      mnemonic_phrase
      |> MnemonicSeed.to_seed()

    assert 0xD525A6EDF12D3919D132788AE3CE0F597430F4C58C4FF6CBAC99609121565DE24FAB6BA7FB247FA2EA3028F8FC80CDE71E7155F6928480644DB2027B8B9A3627 ==
             seed
  end
end
