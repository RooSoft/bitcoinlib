# Examples

## LiveBook examples

Interact with Bitcoin straight from your browser with these [Livebook](https://livebook.dev) documents.

- [Wallet operations](https://github.com/RooSoft/bitcoinlib/blob/main/livebooks/wallet_operations/index.livemd)

## Prerequisite

Let's define some aliases, to simplify this document.

```elixir
alias BitcoinLib.Key.{PrivateKey, PublicKey, PublicKeyHash, Address}
alias BitcoinLib.Key.HD.SeedPhrase
```

## Seed phrase generation from dice rolls

Randomness is of utmost importance when creating Bitcoin keys. That's why we use multiple dice rolls to
make sure private keys are unique. There's a choice of 50 or 99 dice rolls to generate a 12 or 24 word
seed phrase.

```elixir
{:ok, seed_phrase} =
  "12345612345612345612345612345612345612345612345612"
  |> SeedPhrase.from_dice_rolls()
```

```elixir
{:ok, "blue involve cook print twist crystal razor february caution private slim medal"}
```

## Master private key from a seed phrase

The master private key can monitor and spend funds on a range of addresses.

```elixir
master_private_key = 
  seed_phrase
  |> PrivateKey.from_seed_phrase()
```

```elixir
%BitcoinLib.Key.PrivateKey{
  key: <<0xe870b890337e36ad866db34824b47a026db4a03f7f2df48eaf6ede61b1fcbfea::256>>,
  chain_code: <<0xda54909d3b6b377d2654e0887596b49f8e36c4300fdb9eb9e3e43a47dceda789::256>>,
  depth: 0,
  index: 0,
  parent_fingerprint: <<0x00000000::32>>,
  fingerprint: <<0x2aafc40e::32>>
}
```

## Master public key from a master private key

```elixir
master_public_key =
  master_private_key
  |> PublicKey.from_private_key()
```

```elixir
%BitcoinLib.Key.PublicKey{
  key: <<0x03254ed681b40913a4a9c4dc22b920f4bf56cc93ad442f8f9f7e976e166fe9cc56::264>>,
  uncompressed_key: <<0x04254ed681b40913a4a9c4dc22b920f4bf56cc93ad442f8f9f7e976e166fe9cc56ce17fd672862c25f33812262e2792f3082ae91e5480e8cad2a483a018bd7c0d1::520>>,
  chain_code: <<0xda54909d3b6b377d2654e0887596b49f8e36c4300fdb9eb9e3e43a47dceda789::256>>,
  depth: 0,
  index: 0,
  parent_fingerprint: <<0x00000000::32>>,
  fingerprint: <<0x2aafc40e::32>>
}
```

## Generate a P2PKH from a public key

```elixir
address =
  master_public_key
  |> PublicKeyHash.from_public_key()
  |> Address.from_public_key_hash(:mainnet)
```

```elixir
"14thwUvxWWJRZipWUgk1j45LG8qpWu8AxH"
```
