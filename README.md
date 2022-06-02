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

## Public key generation

```elixir
private_key = "0a8d286b11b98f6cb2585b627ff44d12059560acd430dcfa1260ef2bd9569373"

{uncompressed, compressed} =
  private_key
  |> BitcoinLib.derive_public_key()
```
