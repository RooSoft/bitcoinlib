alias BitcoinLib.Console
alias BitcoinLib.Key.Address
alias BitcoinLib.Key.HD.{DerivationPath, Entropy, ExtendedPublic, ExtendedPrivate, MnemonicSeed}

# options here https://hexdocs.pm/elixir/1.12/Inspect.Opts.html
# IEx.configure(
#   inspect: [base: :hex]
# )

private_key =
  "01234501234501234501234501234501234501234501234501"
  |> Entropy.from_dice_rolls!()
  |> MnemonicSeed.wordlist_from_entropy()
  |> MnemonicSeed.to_seed()
  |> ExtendedPrivate.from_seed()

public_key =
  private_key
  |> ExtendedPublic.from_private_key()

ss_private_key =
  ExtendedPrivate.from_mnemonic_phrase("rally celery split order almost twenty ignore record legend learn chaos decade")

ss_xpriv =
  ss_private_key
  # this child is: bip 44 bitcoin mainnet account 0 receiving index 0
  |> ExtendedPrivate.from_derivation_path!("m/49'/0'/0'/0/0")
  |> ExtendedPrivate.serialize()


blue_wallet_pub_key =
  ss_private_key
  |> ExtendedPrivate.from_derivation_path!("m/49'/0'/0'")
  |> ExtendedPublic.from_private_key()

blue_wallet_xpub =
  blue_wallet_pub_key
  |> ExtendedPublic.serialize()

blue_wallet_address_0_pub_key =
  blue_wallet_pub_key
  |> ExtendedPublic.derive_child!(0)
  |> ExtendedPublic.derive_child!(0)

blue_wallet_address_0 =
  blue_wallet_address_0_pub_key
  |> ExtendedPublic.to_address(:p2pkh)
