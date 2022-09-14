# Addresses

Addresses are derived from a public key and can be used to receive funds or track balances.

## Creation

First, we need a public key

```elixir
alias BitcoinLib.Key.{PrivateKey, PublicKey}

public_key = 
  "blue involve cook print twist crystal razor february caution private slim medal"
  |> PrivateKey.from_seed_phrase()
  |> PublicKey.from_private_key()
```

One public key corresponds to a single address... Here is how it's being converted

```elixir
public_key
|> PublicKey.to_address()
```

which results in

```
bc1q92hugrsmv52fr5fp2axycdg7fz4ssr66spdajs
```