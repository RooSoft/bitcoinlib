# Private key creation

The private key is your identity. You can use it to receive and spend funds, 
as well as view how much is associated with it. Banks ask for documents 
to prove who you are. In Bitcoin, all that's required is a very very large number
that you can issue by yourself. The more random the number, the more secure
are your funds.

The way BitcoinLib deals with this is by creating `entropy` from dice rolls
and then convert it into either a 12 or 24 words `mnemonic phrase`.

## Mnemonic phrase from dice rolls

![99 dices](https://raw.githubusercontent.com/RooSoft/bitcoinlib/main/guides/assets/images/99dice.jpg)

BitcoinLib offers a way to generate very random entropy by rolling 50 or 99 dices,
depending on the level of security you're after. These will introduce either 2^132
or 2^264 possibilities, depending on the number of rolls.

Here is an example of private key creation. Note here that every dice roll value has
been reduced by 1 so that values range from 0 to 5.

```elixir
alias BitcoinLib.Key.HD.{Entropy, MnemonicSeed}

wordlist = 
  "01234501234501234501234501234501234501234501234501"
  |> Entropy.from_dice_rolls!()
  |> MnemonicSeed.wordlist_from_entropy()

assert wordlist == [
  "blue", "involve", "cook", "print", 
  "twist", "crystal", "razor", "february",
  "caution", "private", "slim", "medal"
]
```

## Private key from mnemonics

This mnemonic phrase can then be converted into a `private key`

```elixir
alias BitcoinLib.Key.HD.ExtendedPrivate

private_key = 
  "blue involve cook print twist crystal razor february caution private slim medal"
  |> ExtendedPrivate.from_mnemonic_phrase()

assert %BitcoinLib.Key.HD.ExtendedPrivate{
  chain_code: 98753614235036553155428756621915230475895182258496493972608878370221250684809,
  depth: 0,
  fingerprint: 716162062,
  index: 0,
  key: 105135741551555958813494755273405117169669837034836946126935268988599184179178,
  parent_fingerprint: 0
} = private_key
```