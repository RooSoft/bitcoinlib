defmodule BitcoinLib.Test.Integration.Bip84.ZpubFromMnemonicTest do
  @moduledoc """
  based on https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#test-vectors
  """
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.HD.{MnemonicSeed, ExtendedPublic, ExtendedPrivate}

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
end
