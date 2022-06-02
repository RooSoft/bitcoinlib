# BitcoinLib

Bitcoin helpers such as:

- Creation of
  - Private Keys
  - Public Keys
  - P2PKH addresses

## Private key generation

```elixir
%{
  raw: private_key, 
  wif: wif_version
} = BitcoinLib.generate_private_key()
```

## Public key derivation

```elixir
private_key = "0a8d286b11b98f6cb2585b627ff44d12059560acd430dcfa1260ef2bd9569373"

{uncompressed, compressed} =
  private_key
  |> BitcoinLib.derive_public_key()
```

## Generate a P2PKH from a public key

```elixir
compressed_public_key = "020f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053"

address =
  compressed_public_key
  |> BitcoinLib.generate_p2pkh_address()
```

```
1Ak9NVPmwCHEpsSWvM6cNRC7dsYniRmwMG
```
