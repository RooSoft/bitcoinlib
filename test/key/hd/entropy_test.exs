defmodule BitcoinLib.Key.HD.EntropyTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.Entropy

  alias BitcoinLib.Key.HD.Entropy

  test "create an entropy value out of 50 dice rolls" do
    dice_rolls = "01234501234501234501234501234501234501234501234501"

    {:ok, entropy} = Entropy.from_dice_rolls(dice_rolls)

    assert entropy == 32_310_461_525_491_050_757_677_748_469_648_273_221
  end

  test "try to extract entropy out of an invalid dice roll string" do
    dice_rolls = "12345612345612345612345612345612345612345612345612"

    {:error, message} = Entropy.from_dice_rolls(dice_rolls)

    assert message == "dice_rolls contains invalid characters outside of this range [0,5]"
  end
end
