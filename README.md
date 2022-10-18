# BitcoinLib

![Bitcoin](https://raw.githubusercontent.com/RooSoft/bitcoinlib/main/guides/assets/images/bitcoin.svg)
![Elixir](https://raw.githubusercontent.com/RooSoft/bitcoinlib/main/guides/assets/images/elixir-with-name.svg)

Want to interact with the Bitcoin network through a DIY app? Look no further, this library 
is about doing it with [Elixir](https://elixir-lang.org) in a very abstract way. It 
keeps the cryptography jargon to a minimum, while sticking to the 
[Bitcoin glossary](https://developer.bitcoin.org/glossary.html).

The easiest way to start is to try the [wallet operations livebook](https://github.com/RooSoft/bitcoinlib/blob/main/livebooks/wallet_operations/index.livemd).

## How to use

First, make sure you've got [elixir set up](https://elixir-lang.org/install.html) and that you
[know the language's basics](https://elixircasts.io/series/learn-elixir).

Then, create a project and add the dependency in `mix.exs`.

```elixir
def deps do
  [
    {:bitcoinlib, "~> 0.2.3"}
  ]
end
```

Finally, head to the [private key creation](https://hexdocs.pm/bitcoinlib/tutorial-private-key.html) 
documentation to get started.

## Useful links

Here are the most useful links 

- [Hex package](https://hex.pm/packages/bitcoinlib) 
- [Hex documentation](https://hexdocs.pm/bitcoinlib/readme.html)
- [Git repository](https://github.com/RooSoft/bitcoinlib)
- [Useful links](https://hexdocs.pm/bitcoinlib/links.html)
- [Examples](https://hexdocs.pm/bitcoinlib/examples.html)


## Technicalities

### This lib can

- Generate entropy with dice rolls
- Create private keys
- Derive public keys from private keys
- Handle Hierarchical Deterministic (HD) Wallets, including
  - Seed Phrases
  - Derivation Paths
- Serialize/Deserialize Private Keys (`xprv`, `yprv`, `zprv`)
- Serialize/Deserialize Public Keys  (`xpub`, `ypub`, `zpub`)
- Generate Addresses
- Sign P2PKH transactions

#### Mid term goals

- Sign Transactions (PSBT)
- Taproot support

### Supported address types

| Address Type          | Description             | Starts With  | Supported     |
|-----------------------|-------------------------|--------------|---------------|
| P2PKH                 | Pay to Primary Key Hash | `1`          | ✅            |
| P2WPKH-nested-in-P2SH | Nested Segwit           | `3`          | ✅            |
| P2WPKH                | Native Segwit           | `bc1q`       | ✅            |
| P2TR                  | Taproot                 | `bc1p`       | Eventually... |

### Referenced bips

A bip is a [Bitcoin Improvement Proposal](https://github.com/bitcoin/bips#readme). Here is a list 
of those that are at least partially implemented in this library:

- [bip13](https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki) - Address Format for pay-to-script-hash
- [bip16](https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki) - Pay to Script Hash
- [bip32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) - Hierarchical Deterministic Wallets
- [bip39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) - Mnemonic code for generating deterministic keys
- [bip44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) - Multi-Account Hierarchy for Deterministic Wallets
- [bip49](https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki) - Derivation scheme for P2WPKH-nested-in-P2SH based accounts
- [bip84](https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki) - Derivation scheme for P2WPKH based accounts
- [bip141](https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki) - Segregated Witness (Consensus layer)
- [bip144](https://github.com/bitcoin/bips/blob/master/bip-0144.mediawiki) - Segregated Witness (Peer Services)
- [bip173](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki) - Base32 address format for native v0-16 witness outputs
- [bip174](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki) - Partially Signed Bitcoin Transaction Format

#### PSBT bips, in the process of being implemented

- [bip370](https://github.com/bitcoin/bips/blob/master/bip-0370.mediawiki) - PSBT Version 2

## Running static analysis

```bash
$ mix deps.get
$ mix test
$ mix dialyzer
```