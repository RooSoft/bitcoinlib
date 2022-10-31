defmodule BitcoinLib.Test.Integration.Transactions.SignAPsbtTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.PrivateKey
  alias BitcoinLib.Signing.Psbt

  test "sign a psbt" do
    master_private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> PrivateKey.from_seed_phrase()

    encoded_psbt =
      "cHNidP8BAFUCAAAAAa9Jmng5yZPFGXXTReHx6z8d1O38tum3DhQjbf9Lf5VaAAAAAAD9////AbbkEwAAAAAAGXapFAXhfAL7I4ygd5s1MycevpFrAbyriKw5SSQATwEENYfPA6136DyAAAAAwMdgGUB7VVRVi0r+ISOljwlbxYuQgu4Y57F7P3WL1OsDGK24P3wNkAglKWbuzC3RYaLtP9wTWd5RS7JQ2WRk8XcQLpKnTCwAAIABAACAAAAAgAABAL8CAAAAAdjgWv1LftSjy/F1bsum7yIZd5YHMjanq/JmpXp2WODdAQAAAGpHMEQCIDTZU9MowsRKzEg/8622xOLKR8tYYkcd6NCEvZjSWMFnAiAM/D/w5U4I3Eohe2McrBnt97u9UybhPplg6UopK4YhnQEhAs1DEZRoupv6IHEXjrx80K6Maq2AsCo4GtHSmZ7vSwvS/f///wF25RMAAAAAABl2qRQCcoU3NvPdCSSAVQSf8V3/CdfwD4isddEjAAEDBAEAAAAiBgLjFLcTTcsYE9xBNTl6WMUl7i2DnNF7Tb//aiTG/flrSRgukqdMLAAAgAEAAIAAAACAAQAAAAEAAAAAAA=="

    {:ok, psbt} = Psbt.parse(encoded_psbt)

    input =
      psbt
      |> Map.get(:inputs)
      |> List.first()

    bip32_derivation =
      input
      |> Map.get(:bip32_derivations)
      |> List.first()
      |> IO.inspect()

    private_derivation_path =
      bip32_derivation.derivation_path
      |> IO.inspect()

    {:ok, private_key} =
      master_private_key
      |> PrivateKey.from_derivation_path(private_derivation_path)

    IO.inspect(private_key)
  end
end
