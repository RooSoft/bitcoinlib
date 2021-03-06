defmodule BitcoinLib.Test.Integration.Bip84.ZpubFromMnemonicTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.HD.{MnemonicSeed, ExtendedPublic, ExtendedPrivate}

  @doc """
  based on https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#test-vectors
  """
  test "generate zpub from a mnemonic phrase" do
    private_key =
      "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
      |> MnemonicSeed.to_seed()
      |> ExtendedPrivate.from_seed()

    {:ok, zpub} =
      private_key
      |> ExtendedPrivate.from_derivation_path!("m/84'/0'/0'")
      |> ExtendedPublic.from_private_key()
      |> ExtendedPublic.serialize(:zpub)

    assert zpub ==
             "zpub6rFR7y4Q2AijBEqTUquhVz398htDFrtymD9xYYfG1m4wAcvPhXNfE3EfH1r1ADqtfSdVCToUG868RvUUkgDKf31mGDtKsAYz2oz2AGutZYs"
  end

  test "alternative version of zpub from mnemonic phrase" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> MnemonicSeed.to_seed()
      |> ExtendedPrivate.from_seed()

    {:ok, zpub} =
      private_key
      |> ExtendedPrivate.from_derivation_path!("m/84'/0'/0'")
      |> ExtendedPublic.from_private_key()
      |> ExtendedPublic.serialize(:zpub)

    assert zpub ==
             "zpub6qYAt4j2n3Vp2smwHWGYUctcxqiG6uX5fDqiWcWT98NKhwwEJGwsqaU6rFSbCQL5q7s1FBqgHALYRVQdYKQWgM6cgbA5p81vPp7ST6Aqx9Q"
  end
end
