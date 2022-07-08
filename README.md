# BitcoinLib

![Bitcoin](https://raw.githubusercontent.com/RooSoft/bitcoinlib/main/guides/assets/images/bitcoin.svg)
![Elixir](https://raw.githubusercontent.com/RooSoft/bitcoinlib/main/guides/assets/images/elixir-with-name.svg)

Want to interact with the Bitcoin network through a DIY app? Look no further, this library 
is about doing it with [Elixir](https://elixir-lang.org), whether you know what it is or not 
in the simplest way possible. It makes abstraction of most of the cryptography jargon, while sticking
to the [Bitcoin glossary](https://developer.bitcoin.org/glossary.html).

# How to use

First, make sure you've got [elixir set up](https://elixir-lang.org/install.html) and that you
[know the language's basics](https://elixircasts.io/series/learn-elixir).

Then, create a project and add the dependency in `mix.exs`.

```elixir
def deps do
  [
    {:bitcoinlib, "~> 0.1.2"}
  ]
end
```

Finally, head to the [private key creation](https://hexdocs.pm/bitcoinlib/tutorial-private-key.html) 
documentation to get started.

# Useful links

Here are the most useful links 

- [Hex package](https://hex.pm/packages/bitcoinlib) 
- [Hex documentation](https://hexdocs.pm/bitcoinlib/readme.html)
- [Git repository](https://github.com/RooSoft/bitcoinlib)
- [Useful links](https://hexdocs.pm/bitcoinlib/links.html)
- [Examples](https://hexdocs.pm/bitcoinlib/examples.html)


# Technicalities

## This lib can

- Generate entropy with dice rolls
- Create private keys
- Derive public keys from private keys
- Handle Hierarchical Deterministic (HD) Wallets, including
  - Mnemonic Phrases
  - Derivation Paths
- Serialize/Deserialize Private Keys (`xprv`, `yprv`, `zprv`)
- Serialize/Deserialize Public Keys  (`xpub`, `ypub`, `zpub`)
- Generate Addresses

### Mid term goals

- Sign Transactions (PSBT)
- Taproot support

## Address types

| Address Type          | Description             | Starts With  | Supported     |
|-----------------------|-------------------------|--------------|---------------|
| P2PKH                 | Pay to Primary Key Hash | `1`          | ✅            |
| P2WPKH-nested-in-P2SH | Nested Segwit           | `3`          | ✅            |
| P2WPKH                | Native Segwit           | `bc1q`       | ✅            |
| P2TR                  | Taproot                 | `bc1p`       | Eventually... |

## Referenced bitcoin improvement proposals (bips)
- [bip13](https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki) - Address Format for pay-to-script-hash
- [bip16](https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki) - Pay to Script Hash
- [bip32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) - Hierarchical Deterministic Wallets
- [bip39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) - Mnemonic code for generating deterministic keys
- [bip44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) - Multi-Account Hierarchy for Deterministic Wallets
- [bip49](https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki) - Derivation scheme for P2WPKH-nested-in-P2SH based accounts
- [bip84](https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki) - Derivation scheme for P2WPKH based accounts
- [bip141](https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki) - Segregated Witness (Consensus layer)
- [bip173](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki) - Base32 address format for native v0-16 witness outputs
