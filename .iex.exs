alias BitcoinLib.Key.HD.{Entropy, ExtendedPublic, ExtendedPrivate, MnemonicSeed}

dice_rolls = "01234501234501234501234501234501234501234501234501"
{:ok, entropy} = Entropy.from_dice_rolls(dice_rolls)
mnemonics = MnemonicSeed.wordlist_from_entropy(entropy)
seed = MnemonicSeed.to_seed(mnemonics)
private_key = ExtendedPrivate.from_seed(seed)
public_key = ExtendedPublic.from_private_key(private_key)

#ss_mnemonics = "rally celery split order almost twenty ignore record legend learn chaos decade"
#ss_seed = BitcoinLib.Key.HD.MnemonicSeed.to_seed(mnemonics)
ss_seed = "000102030405060708090a0b0c0d0e0f"
ss_pk = ExtendedPrivate.from_seed(ss_seed)
{:ok, child_pk} = ExtendedPrivate.derive_child(ss_pk, 0)
child_pub_key = ExtendedPublic.from_private_key(child_pk)

identifier = child_pub_key.key
|> Integer.to_string(16)
|> String.downcase()
|> BitcoinLib.Crypto.sha256()
|> BitcoinLib.Crypto.ripemd160()

xprv = ExtendedPrivate.serialize_master_private_key(ss_pk)


pk =
  "b1680c7a6ea6ed5ac9bf3bc3b43869a4c77098e60195bae51a94159333820e125c3409b8c8d74b4489f28ce71b06799b1126c1d9620767c2dadf642cf787cf36"
  |> ExtendedPrivate.from_seed
