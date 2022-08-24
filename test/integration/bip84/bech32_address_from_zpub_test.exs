defmodule BitcoinLib.Test.Integration.Bip84.Bech32AddressFromZpub do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Key.HD.{MnemonicSeed}

  @doc """
  based on https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#test-vectors
  """
  test "generate m/84'/0'/0'/0/0 bech32 address from a mnemonic phrase" do
    private_key =
      "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
      |> MnemonicSeed.to_seed()
      |> PrivateKey.from_seed()

    address =
      private_key
      |> PrivateKey.from_derivation_path!("m/84'/0'/0'/0/0")
      |> PublicKey.from_private_key()
      |> PublicKey.to_address(:bech32)

    assert address == "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu"
  end

  @doc """
  based on https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#test-vectors
  """
  test "generate m/84'/0'/0'/0/1 bech32 address from a mnemonic phrase " do
    private_key =
      "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
      |> MnemonicSeed.to_seed()
      |> PrivateKey.from_seed()

    address =
      private_key
      |> PrivateKey.from_derivation_path!("m/84'/0'/0'/0/1")
      |> PublicKey.from_private_key()
      |> PublicKey.to_address(:bech32)

    assert address == "bc1qnjg0jd8228aq7egyzacy8cys3knf9xvrerkf9g"
  end

  @doc """
  based on https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#test-vectors
  """
  test "generate m/84'/0'/0'/1/0 bech32 address from a mnemonic phrase" do
    private_key =
      "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
      |> MnemonicSeed.to_seed()
      |> PrivateKey.from_seed()

    address =
      private_key
      |> PrivateKey.from_derivation_path!("m/84'/0'/0'/1/0")
      |> PublicKey.from_private_key()
      |> PublicKey.to_address(:bech32)

    assert address == "bc1q8c6fshw2dlwun7ekn9qwf37cu2rn755upcp6el"
  end

  test "generate bech32 address from an alternate mnemonic phrase" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> MnemonicSeed.to_seed()
      |> PrivateKey.from_seed()

    address =
      private_key
      |> PrivateKey.from_derivation_path!("m/84'/0'/0'/0/0")
      |> PublicKey.from_private_key()
      |> PublicKey.to_address(:bech32)

    assert address == "bc1qcmxt22gjgvy74cjtf73r3hzwfg249tql6ps767"
  end
end
