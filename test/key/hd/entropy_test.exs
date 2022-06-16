defmodule BitcoinLib.Key.HD.EntropyTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.Entropy

  alias BitcoinLib.Key.HD.Entropy

  test "create an entropy value out of 50 dice rolls" do
    dice_rolls = "012345012345012345012345012345012345012345012345012"

    entropy = Entropy.from_dice_rolls(dice_rolls)

    assert entropy == 193_862_769_152_946_304_546_066_490_817_889_639_328
  end
end
