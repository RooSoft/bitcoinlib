# defmodule BitcoinLib.Test.Integration.Transactions.SignAPsbtTest do
#   use ExUnit.Case, async: true

#   alias BitcoinLib.Key.{PublicKey, PrivateKey}
#   alias BitcoinLib.Signing.Psbt
#   alias BitcoinLib.Transaction
#   alias BitcoinLib.Script

#   test "verify signature" do
#     public_key =
#       "tpubDHeDRHkh1MBjw7DsamnsGir2RPZcJZRGxqpkqjrUDmF5KCSrLXtZkHmqSmGfFf4T2C3rjJqqzhDVBPB58ZVM5fuVBTAJm7LpUviJu4AAj9n"
#       |> PublicKey.deserialize!()

#     signature =
#       <<0x47304402202473AE38708602DB3F90BDB368A8BDA0B6B6F8CAFD55A20B0EA653E28619DC1002207D4F975D9C7CE087BA4D492B43819664CBA4CA1EC17F627B19356C62B6353ADD012102E314B7134DCB1813DC4135397A58C525EE2D839CD17B4DBFFF6A24C6FDF96B49::848>>

#     script_pub_key = [
#       %BitcoinLib.Script.Opcodes.Stack.Dup{},
#       %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
#       %BitcoinLib.Script.Opcodes.Data{value: <<0x0272853736F3DD09248055049FF15DFF09D7F00F::160>>},
#       %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
#       %BitcoinLib.Script.Opcodes.Crypto.CheckSig{
#         script: <<0x76A9140272853736F3DD09248055049FF15DFF09D7F00F88AC::200>>
#       }
#     ]

#     Script.execute(script_pub_key, [public_key.key, signature])
#   end

#   test "sign a psbt" do
#     master_private_key =
#       "rally celery split order almost twenty ignore record legend learn chaos decade"
#       |> PrivateKey.from_seed_phrase()

#     encoded_psbt =
#       "cHNidP8BAFUCAAAAAa9Jmng5yZPFGXXTReHx6z8d1O38tum3DhQjbf9Lf5VaAAAAAAD9////AbbkEwAAAAAAGXapFAXhfAL7I4ygd5s1MycevpFrAbyriKw5SSQATwEENYfPA6136DyAAAAAwMdgGUB7VVRVi0r+ISOljwlbxYuQgu4Y57F7P3WL1OsDGK24P3wNkAglKWbuzC3RYaLtP9wTWd5RS7JQ2WRk8XcQLpKnTCwAAIABAACAAAAAgAABAL8CAAAAAdjgWv1LftSjy/F1bsum7yIZd5YHMjanq/JmpXp2WODdAQAAAGpHMEQCIDTZU9MowsRKzEg/8622xOLKR8tYYkcd6NCEvZjSWMFnAiAM/D/w5U4I3Eohe2McrBnt97u9UybhPplg6UopK4YhnQEhAs1DEZRoupv6IHEXjrx80K6Maq2AsCo4GtHSmZ7vSwvS/f///wF25RMAAAAAABl2qRQCcoU3NvPdCSSAVQSf8V3/CdfwD4isddEjAAEDBAEAAAAiBgLjFLcTTcsYE9xBNTl6WMUl7i2DnNF7Tb//aiTG/flrSRgukqdMLAAAgAEAAIAAAACAAQAAAAEAAAAAAA=="

#     {:ok, psbt} = Psbt.parse(encoded_psbt) |> IO.inspect()

#     derivation_path =
#       psbt
#       |> Map.get(:inputs)
#       |> List.first()
#       |> Map.get(:bip32_derivations)
#       |> List.first()
#       |> Map.get(:derivation_path)
#       |> IO.inspect()

#     {:ok, private_key} =
#       master_private_key
#       |> PrivateKey.from_derivation_path(derivation_path)

#     BitcoinLib.Key.PublicKey.from_private_key(private_key)
#     |> BitcoinLib.Key.PublicKey.serialize(:testnet, :bip32)
#     |> IO.inspect(label: "public key")

#     unsigned_transaction =
#       psbt
#       |> Map.get(:global)
#       |> Map.get(:unsigned_tx)

#     #  encoded_signed_transaction =
#     unsigned_transaction
#     |> Transaction.sign_and_encode(private_key)
#     |> IO.inspect()

#     assert 5 == private_key.depth
#   end
# end
