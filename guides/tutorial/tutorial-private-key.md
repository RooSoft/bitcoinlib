# Private key creation

The private key is your identity. You can use it to receive and spend funds, 
as well as view how much is associated with it. Banks ask for documents 
to prove who you are. In Bitcoin, all that's required is a very very large number
that you can issue by yourself. The more random the number, the more secure
are your funds.

The way BitcoinLib deals with this is by creating `entropy` from dice rolls
and then convert it into either a 12 or 24 words `mnemonic phrase`.

# Mnemonic phrase from dice rolls

![99 dices](/guides/assets/images/99dice.jpg)

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
