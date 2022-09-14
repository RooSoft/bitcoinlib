# Public Keys

A public key is derived from a [private key](tutorial-private-key.html). The main difference is that it
can't be used to spend funds. It still is able to view balances and create addresses.

## Creation

First, a private key is needed...

```elixir
alias BitcoinLib.Key.{PrivateKey, PublicKey}

private_key = 
  "blue involve cook print twist crystal razor february caution private slim medal"
  |> PrivateKey.from_seed_phrase()
```

... so that the public key can be derived from it

```elixir
public_key =
  private_key
  |> PublicKey.from_private_key()
```

## Serialization

A public key can be serialized into an `xpub`

```elixir
public_key
|> PublicKey.serialize!()
```

which results in

```elixir
"xpub661MyMwAqRbcGiWUazDmCUZbC8Z7WMcjveWgfU92NAu4kvFcpZ8LGV2Y4bRaT8sBUzihLgiyMqsbb61HKFV1sL185uZs1DE15dpWfrQFqBY"
```

and can then be imported in an online app to generate a `read-only wallet`