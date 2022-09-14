# Key derivation

For reference, is a very 
[nice doc describing derivatoin paths](https://learnmeabitcoin.com/technical/derivation-paths).
At the moment, `bip44`, `bip49` and `bip84` `purposes` are supported, with `taproot` being the next
in line.

## Create the bip84 Bitcoin account #0

Starting from a seed phrase, down to the private key

```elixir
"blue involve cook print twist crystal razor february caution private slim medal"
|> PrivateKey.from_seed_phrase()
|> PrivateKey.from_derivation_path!("m/84'/0'/0'")
```

This will result in a bitcoin bech32 private key that can further be derivated twice

```elixir
%BitcoinLib.Key.PrivateKey{
  key: <<0x812aa97c4beb9399f95bb762984a50002b8362da505d014dc476534a524c97be::256>>,
  chain_code: <<0xd98673927874380df0d69a0ff632cffa1aad20805fb6169cf429820496e2c585::256>>,
  depth: 3,
  index: 2147483648,
  parent_fingerprint: <<0x78a5dfb2::32>>,
  fingerprint: <<0x00000000::32>>
}
```

Notice the depth of 3, which matches the derivation path.