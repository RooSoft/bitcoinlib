defmodule BitcoinLib.Key.HD.Entropy do
  def from_dice_rolls(dice_rolls) do
    dice_rolls
    |> Integer.parse(6)
    |> elem(0)
  end
end
