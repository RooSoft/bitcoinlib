dice_rolls = "01234501234501234501234501234501234501234501234501"
{:ok, entropy} = BitcoinLib.Key.HD.Entropy.from_dice_rolls(dice_rolls)
mnemonics = BitcoinLib.Key.HD.MnemonicSeed.wordlist_from_entropy(entropy)
seed = BitcoinLib.Key.HD.MnemonicSeed.to_seed(mnemonics)
private_key = BitcoinLib.Key.HD.ExtendedPrivate.from_seed(seed)
public_key = BitcoinLib.Key.HD.ExtendedPublic.from_private_key(private_key)

#ss_mnemonics = "rally celery split order almost twenty ignore record legend learn chaos decade"
#ss_seed = BitcoinLib.Key.HD.MnemonicSeed.to_seed(mnemonics)
ss_seed = "000102030405060708090a0b0c0d0e0f"
ss_pk = BitcoinLib.Key.HD.ExtendedPrivate.from_seed(ss_seed)
{:ok, child_pk} = BitcoinLib.Key.HD.ExtendedPrivate.derive_child(ss_pk, 0)
child_pub_key = BitcoinLib.Key.HD.ExtendedPublic.from_private_key(child_pk)

identifier = child_pub_key.key
|> Integer.to_string(16)
|> String.downcase()
|> BitcoinLib.Crypto.sha256()
|> BitcoinLib.Crypto.ripemd160()

xprv = BitcoinLib.Key.HD.ExtendedPrivate.serialize_master_private_key(ss_pk)
