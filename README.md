# BitcoinLib

Bitcoin helpers such as:

- Creation of
  - Private Keys
  - Public Keys
  - P2PKH addresses

## referenced bitcoin improvement proposals (bips)
- [bip13](https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki) - Address Format for pay-to-script-hash
- [bip16](https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki) - Pay to Script Hash
- [bip32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) - Hierarchical Deterministic Wallets
- [bip39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) - Mnemonic code for generating deterministic keys
- [bip44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) - Multi-Account Hierarchy for Deterministic Wallets
- [bip49](https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki) - Derivation scheme for P2WPKH-nested-in-P2SH based accounts
- [bip84](https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki) - Derivation scheme for P2WPKH based accounts
- [bip141](https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki) - Segregated Witness (Consensus layer)
- [bip173](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki) - Base32 address format for native v0-16 witness outputs

## Private key generation

```elixir
%{
  raw: private_key, 
  wif: wif_version
} = BitcoinLib.generate_private_key()
```

```elixir
%{
  raw: 85802653936839865013864937414198608060921225918071701559735074585839951298352,
  wif: "L3aTXceEuyR8roYKSjY4yw6GYchZSRmxoKLHpUKJYkNGeLwccE6b"
}
```

## Public key derivation

```elixir
private_key = "0a8d286b11b98f6cb2585b627ff44d12059560acd430dcfa1260ef2bd9569373"

{uncompressed, compressed} =
  private_key
  |> BitcoinLib.derive_public_key()
```

```elixir
{
  "040f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053002119e16b613619691f760eadd486315fc9e36491c7adb76998d1b903b3dd12",
  "020f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053"
|}
```

## Generate a P2PKH from a public key

```elixir
compressed_public_key = "020f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053"

address =
  compressed_public_key
  |> BitcoinLib.generate_p2pkh_address()
```

```elixir
1Ak9NVPmwCHEpsSWvM6cNRC7dsYniRmwMG
```

## Useful links

- [BIP32 Deterministic Key Generator](http://bip32.org)
- [Registered HD version bytes](https://github.com/satoshilabs/slips/blob/master/slip-0132.md#registered-hd-version-bytes)