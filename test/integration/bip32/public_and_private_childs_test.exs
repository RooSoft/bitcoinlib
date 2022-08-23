defmodule BitcoinLib.Test.Integration.Bip32.PublicAndPrivateChildsTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.{PrivateKey}
  alias BitcoinLib.Key.HD.{MnemonicSeed, ExtendedPublic}

  test "compare public key childs obtained in two different ways" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> MnemonicSeed.to_seed()
      |> PrivateKey.from_seed()

    xpub_from_private =
      private_key
      |> PrivateKey.derive_child!(0)
      |> ExtendedPublic.from_private_key()
      |> ExtendedPublic.serialize()

    xpub_from_public =
      private_key
      |> ExtendedPublic.from_private_key()
      |> ExtendedPublic.derive_child!(0)
      |> ExtendedPublic.serialize()

    assert xpub_from_private == xpub_from_public
  end
end
