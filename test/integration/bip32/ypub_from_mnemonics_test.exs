defmodule BitcoinLib.Test.Integration.Bip32.YpubFromMnemonicsTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.HD.{ExtendedPrivate, ExtendedPublic, MnemonicSeed}

  test "convert a mnemonic phrase into a ypub" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> MnemonicSeed.to_seed()
      |> ExtendedPrivate.from_seed()

    public_key =
      private_key
      |> ExtendedPrivate.from_derivation_path!("m/49'/0'/0'")
      |> ExtendedPublic.from_private_key()

    {:ok, ypub} =
      public_key
      |> ExtendedPublic.serialize(:ypub)

    assert "ypub6WwZCtcXYyyL6GHQrB8pnaHRNCaAWhuQkQraCKUk7qpF4JmVgwMAvaCu9m6o9nAeyFRqw6xyZxG7CDf16GMHFYbtw8KCtNsgkRoRs7YFJf9" =
             ypub
  end
end
