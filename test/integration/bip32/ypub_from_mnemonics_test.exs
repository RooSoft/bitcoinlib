defmodule BitcoinLib.Test.Integration.Bip32.YpubFromMnemonicsTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Key.HD.{MnemonicSeed}

  test "convert a mnemonic phrase into a ypub" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> MnemonicSeed.to_seed()
      |> PrivateKey.from_seed()

    public_key =
      private_key
      |> PrivateKey.from_derivation_path!("m/49'/0'/0'")
      |> PublicKey.from_private_key()

    {:ok, ypub} =
      public_key
      |> PublicKey.serialize(:ypub)

    assert "ypub6WwZCtcXYyyL6GHQrB8pnaHRNCaAWhuQkQraCKUk7qpF4JmVgwMAvaCu9m6o9nAeyFRqw6xyZxG7CDf16GMHFYbtw8KCtNsgkRoRs7YFJf9" =
             ypub
  end
end
