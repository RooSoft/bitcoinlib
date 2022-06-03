%{raw: pk} =

BitcoinLib.generate_private_key()
|> Map.get("raw")
|> BitcoinLib.derive_public_key()
|> elem(1)
|> BitcoinLib.generate_p2pkh_address()
