defmodule BitcoinLib.Test.Integration.Bip84.ZpubFromSeedPhraseTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.{PrivateKey, PublicKey}

  @doc """
  based on https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#test-vectors
  """
  test "generate zpub from a seed phrase" do
    private_key =
      "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
      |> PrivateKey.from_seed_phrase()

    {:ok, zpub} =
      private_key
      |> PrivateKey.from_derivation_path!("m/84'/0'/0'")
      |> PublicKey.from_private_key()
      |> PublicKey.serialize(:mainnet, :bip84)

    assert zpub ==
             "zpub6rFR7y4Q2AijBEqTUquhVz398htDFrtymD9xYYfG1m4wAcvPhXNfE3EfH1r1ADqtfSdVCToUG868RvUUkgDKf31mGDtKsAYz2oz2AGutZYs"
  end

  test "alternative version of zpub from seed phrase" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> PrivateKey.from_seed_phrase()

    {:ok, zpub} =
      private_key
      |> PrivateKey.from_derivation_path!("m/84'/0'/0'")
      |> PublicKey.from_private_key()
      |> PublicKey.serialize(:mainnet, :bip84)

    assert zpub ==
             "zpub6qYAt4j2n3Vp2smwHWGYUctcxqiG6uX5fDqiWcWT98NKhwwEJGwsqaU6rFSbCQL5q7s1FBqgHALYRVQdYKQWgM6cgbA5p81vPp7ST6Aqx9Q"
  end
end
