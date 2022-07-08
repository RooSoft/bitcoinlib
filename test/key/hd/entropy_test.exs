defmodule BitcoinLib.Key.HD.EntropyTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.Entropy

  alias BitcoinLib.Key.HD.Entropy

  test "create an entropy value out of 50 dice rolls" do
    dice_rolls = "12345612345612345612345612345612345612345612345612"

    {:ok, entropy} = Entropy.from_dice_rolls(dice_rolls)

    assert entropy == 0x184EC4BED56EB86AACAAA224B5672F45
  end

  test "create an entropy value out of 99 dice rolls" do
    dice_rolls =
      "123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123456123"

    {:ok, entropy} = Entropy.from_dice_rolls(dice_rolls)

    assert entropy == 0x99F8437B4996F903267CE4A8C0F47ADD78DFE53887DC3965197CCDC406B1BA0
  end

  test "create an entropy with a wrong number of rolls" do
    dice_rolls =
      "12345612345612345612345612345612345612345612345612345612345612345612345612345612345612345612345612"

    {:error, message} = Entropy.from_dice_rolls(dice_rolls)

    assert message =~ "got 98"
  end

  test "try to extract entropy out of an invalid dice roll string" do
    dice_rolls = "01234501234501234501234501234501234501234501234501"

    {:error, message} = Entropy.from_dice_rolls(dice_rolls)

    assert message =~ "Please provide characters inside the [1,6] range"
  end
end
