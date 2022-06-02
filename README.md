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
