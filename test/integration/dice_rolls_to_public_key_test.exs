defmodule BitcoinLib.Test.Integration.DiceRollsToPublicKeyTest do
  use ExUnit.Case, async: true

  test "create a public key out of dice rolls" do
    dice_rolls = "01234501234501234501234501234501234501234501234501"

    {_, public_key} = create_public_key(dice_rolls)

    assert 0x263D3E2C03BE20C3F282EE7AF4D3174E171E5537815FEB551B4B033502251CBE4 == public_key
  end

  defp create_public_key(dice_rolls) do
    BitcoinLib.Key.HD.Entropy.from_dice_rolls(dice_rolls)
    |> elem(1)
    |> BitcoinLib.Key.HD.MnemonicSeed.wordlist_from_entropy()
    |> BitcoinLib.Key.HD.MnemonicSeed.to_seed()
    |> BitcoinLib.Key.HD.ExtendedPrivate.from_seed()
    |> BitcoinLib.Key.HD.ExtendedPublic.from_private_key()
  end
end
