defmodule BitcoinLib.Test.Integration.Bip32.SeedToSerializedKeysTest do
  @moduledoc """
  Values from here: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-1
  """

  use ExUnit.Case, async: true

  alias BitcoinLib.Key.HD.{ExtendedPrivate, ExtendedPublic}

  test "create a private key from a specific seed and output the xprv string" do
    seed = "000102030405060708090a0b0c0d0e0f"

    serialized = create_serialized_master_private_key(seed)

    assert "xprv9s21ZrQL98ze8qqkA6Qkzq2RrHjyUCo1pSNfZDPPAUzbCPc4xehTisZZcrkePLAY8T5AA1xUcm94GFWBVxsphPyrqSvZCbnLZ5d6G8LDgdD" ==
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
    |> ExtendedPrivate.serialize()
  end

  defp create_serialized_master_public_key(seed) do
    seed
    |> ExtendedPrivate.from_seed()
    |> ExtendedPublic.from_private_key()
    |> ExtendedPublic.serialize_master_public_key()
  end
end
