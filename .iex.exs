alias BitcoinLib.Console
alias BitcoinLib.Key.HD.{Entropy, ExtendedPublic, ExtendedPrivate, MnemonicSeed}

# options here https://hexdocs.pm/elixir/1.12/Inspect.Opts.html
IEx.configure(
  inspect: [base: :hex]
)

public_key =
  "01234501234501234501234501234501234501234501234501"
  |> Entropy.from_dice_rolls!()
  |> MnemonicSeed.wordlist_from_entropy()
  |> MnemonicSeed.to_seed()
  |> ExtendedPrivate.from_seed()
  |> ExtendedPublic.from_private_key()

ss_xprv =
  "rally celery split order almost twenty ignore record legend learn chaos decade"
  |> MnemonicSeed.to_seed()
  |> ExtendedPrivate.from_seed()
  # this child is: bip 44 bitcoin mainnet account 0 receiving index 0
  |> ExtendedPrivate.from_derivation_path!("m/44'/0'/0'/0/0")
  |> ExtendedPrivate.serialize()
