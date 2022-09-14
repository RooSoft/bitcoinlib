# Key derivation

For reference, is a very 
[nice doc describing key derivation](https://learnmeabitcoin.com/technical/derivation-paths).
At the moment, `bip44`, `bip49` and `bip84` `purposes` are supported, with `taproot` being the next
in line.

Any `extended private key` can be derived using any of these purposes. Choosing the right one is 
important, as it will impact [address types](https://hexdocs.pm/bitcoinlib/readme.html#address-types) 
generated down the line.

## Create the bip84 Bitcoin account #0

Starting from a seed phrase, down to the private key

```elixir
"blue involve cook print twist crystal razor february caution private slim medal"
|> PrivateKey.from_seed_phrase()
|> PrivateKey.from_derivation_path!("m/84'/0'/0'")
```

This will result in a bitcoin bech32 private key that can further be derivated twice