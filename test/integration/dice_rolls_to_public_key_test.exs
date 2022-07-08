defmodule BitcoinLib.Test.Integration.DiceRollsToPublicKeyTest do
  use ExUnit.Case, async: true

  test "create a public key out of dice rolls" do
    dice_rolls = "12345612345612345612345612345612345612345612345612"

    public_key = create_public_key(dice_rolls)

    assert 0x3254ED681B40913A4A9C4DC22B920F4BF56CC93AD442F8F9F7E976E166FE9CC56 == public_key.key
  end

  defp create_public_key(dice_rolls) do
    BitcoinLib.Key.HD.Entropy.from_dice_rolls!(dice_rolls)
    |> BitcoinLib.Key.HD.MnemonicSeed.wordlist_from_entropy()
    |> BitcoinLib.Key.HD.MnemonicSeed.to_seed()
    |> BitcoinLib.Key.HD.ExtendedPrivate.from_seed()
    |> BitcoinLib.Key.HD.ExtendedPublic.from_private_key()
  end
end
