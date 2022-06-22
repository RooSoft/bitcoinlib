alias BitcoinLib.Console
alias BitcoinLib.Key.HD.{Entropy, ExtendedPublic, ExtendedPrivate, MnemonicSeed}

dice_rolls = "01234501234501234501234501234501234501234501234501"
{:ok, entropy} = Entropy.from_dice_rolls(dice_rolls)
mnemonics = MnemonicSeed.wordlist_from_entropy(entropy)
seed = MnemonicSeed.to_seed(mnemonics)
private_key = ExtendedPrivate.from_seed(seed)
public_key = ExtendedPublic.from_private_key(private_key)

ss_mnemonics = "rally celery split order almost twenty ignore record legend learn chaos decade"
ss_seed = MnemonicSeed.to_seed(mnemonics)
ss_pk = ExtendedPrivate.from_seed(ss_seed)
ss_xprv = ExtendedPrivate.serialize(ss_pk)
