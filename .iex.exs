dice_rolls = "01234501234501234501234501234501234501234501234501"
{:ok, entropy} = BitcoinLib.Key.HD.Entropy.from_dice_rolls(dice_rolls)
mnemonics = BitcoinLib.Key.HD.MnemonicSeed.wordlist_from_entropy(entropy)
seed = BitcoinLib.Key.HD.MnemonicSeed.to_seed(mnemonics)
private_key = BitcoinLib.Key.HD.ExtendedPrivate.from_seed(seed)
public_key = BitcoinLib.Key.HD.ExtendedPublic.from_private_key(private_key.key)
