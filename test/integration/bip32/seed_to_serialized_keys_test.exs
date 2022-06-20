defmodule BitcoinLib.Test.Integration.Bip32.SeedToSerializedKeysTest do
  @moduledoc """
  Values from here: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1
  """

  use ExUnit.Case, async: true

  alias BitcoinLib.Key.HD.{ExtendedPrivate, ExtendedPublic}

  test "create a private key from a specific seed and output the xprv string" do
    seed = "000102030405060708090a0b0c0d0e0f"

    serialized = create_serialized_master_private_key(seed)

    assert "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi" ==
             serialized
  end

  test "create a public key from a specific seed and output the xprv string" do
    seed = "000102030405060708090a0b0c0d0e0f"

    serialized = create_serialized_master_public_key(seed)

    assert "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8" ==
             serialized
  end

  defp create_serialized_master_private_key(seed) do
    seed
    |> ExtendedPrivate.from_seed()
    |> ExtendedPrivate.serialize_master_private_key()
  end

  defp create_serialized_master_public_key(seed) do
    private_key =
      seed
      |> ExtendedPrivate.from_seed()

    {_, public_key} =
      private_key
      |> ExtendedPublic.from_private_key()

    ExtendedPublic.serialize_master_public_key(
      public_key,
      private_key.chain_code
    )
  end
end
