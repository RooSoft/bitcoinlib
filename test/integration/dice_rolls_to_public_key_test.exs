defmodule BitcoinLib.Test.Integration.DiceRollsToPublicKeyTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Key.HD.{Entropy, MnemonicSeed}

  test "create a public key out of dice rolls" do
    dice_rolls = "12345612345612345612345612345612345612345612345612"

    public_key = create_public_key(dice_rolls)

    assert <<0x3254ED681B40913A4A9C4DC22B920F4BF56CC93AD442F8F9F7E976E166FE9CC56::264>> ==
             public_key.key
  end

  defp create_public_key(dice_rolls) do
    Entropy.from_dice_rolls!(dice_rolls)
    |> MnemonicSeed.wordlist_from_entropy()
    |> MnemonicSeed.to_seed()
    |> PrivateKey.from_seed()
    |> PublicKey.from_private_key()
  end
end
