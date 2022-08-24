defmodule BitcoinLib.Test.Integration.Bip32.PublicAndPrivateChildsTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Key.HD.{MnemonicSeed}

  test "compare public key childs obtained in two different ways" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> MnemonicSeed.to_seed()
      |> PrivateKey.from_seed()

    xpub_from_private =
      private_key
      |> PrivateKey.derive_child!(0)
      |> PublicKey.from_private_key()
      |> PublicKey.serialize()

    xpub_from_public =
      private_key
      |> PublicKey.from_private_key()
      |> PublicKey.derive_child!(0)
      |> PublicKey.serialize()

    assert xpub_from_private == xpub_from_public
  end
end
