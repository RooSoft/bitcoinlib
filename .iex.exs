mnemonics = "brick giggle panic mammal document foam gym canvas wheel among room analyst"
seed = BitcoinLib.Key.HD.MnemonicSeed.to_seed(mnemonics)
private_key = BitcoinLib.Key.HD.ExtendedPrivate.from_seed(seed)
public_key = BitcoinLib.Key.HD.ExtendedPublic.from_private_key(private_key.key |> Binary.to_hex)
