# Private keys

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
depending on the level of security you're after. These will introduce either 2¹³²
or 2²⁶⁴ possibilities, depending on the number of rolls.

To get to a private key creation, we first need a mnemonic phrase. Dice rolls will
thus be converted into words. These two notations are equivalent. Note here that 
every dice roll value has been reduced by 1 so that values range from 0 to 5.

```elixir
alias BitcoinLib.Key.HD.{Entropy, MnemonicSeed}

"12345612345612345612345612345612345612345612345612"
|> Entropy.from_dice_rolls!()
|> MnemonicSeed.wordlist_from_entropy()
```

This is the result

```elixir
"blue involve cook print twist crystal razor february caution private slim medal"
```

## Private key from mnemonics

This mnemonic phrase can then be converted into a `private key`

```elixir
alias BitcoinLib.Key.HD.ExtendedPrivate

private_key = 
  "blue involve cook print twist crystal razor february caution private slim medal"
  |> ExtendedPrivate.from_mnemonic_phrase()
```

To keep things simple, we won't bother about what's returned as a private key... just know that
this thing has full access to the wallet that's about to be created in the next steps.

## Serialization

A private key can be serialized into an `xprv`

```elixir
private_key
|> ExtendedPrivate.serialize
```

which results in

```elixir
"xprv9s21ZrQH143K4ES1UxgkqLcre6id6tttZRb5s5jQoqN5t7vUH1p5igi4DKw1E8Dh3EkGtAuKx2RXLTxjJs98uPctYxZrV9TFF1ECi9QNy95"
```

and can then be imported in a wallet, which will have full access to the funds