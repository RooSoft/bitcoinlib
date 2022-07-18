# Addresses

Addresses are derived from a public key and can be used to receive funds or track balances.

## Creation

First, we need a public key

```elixir
alias BitcoinLib.Key.HD.ExtendedPrivate

public_key = 
  "blue involve cook print twist crystal razor february caution private slim medal"
  |> ExtendedPrivate.from_mnemonic_phrase()
  |> ExtendedPublic.from_private_key
```

One public key corresponds to a single address... Here is how it's being converted

```elixir
public_key
|> ExtendedPublic.to_address
```

which results in

```
bc1q92hugrsmv52fr5fp2axycdg7fz4ssr66spdajs
```