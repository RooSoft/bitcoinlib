defmodule BitcoinLib.Test.Integration.Bip32.ChildVsDerivationPathTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.{PrivateKey}

  test "compare values of a child derived private key versus the same with a derivation path" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> PrivateKey.from_seed_phrase()

    manual_xprv = derive_manually(private_key)
    derivation_path_xprv = from_derivation_path(private_key, "m/44'/0'/0'/1/0")

    assert manual_xprv == derivation_path_xprv
  end

  defp derive_manually(private_key) do
    private_key
    |> PrivateKey.derive_child!(44, true)
    |> PrivateKey.derive_child!(0, true)
    |> PrivateKey.derive_child!(0, true)
    |> PrivateKey.derive_child!(1, false)
    |> PrivateKey.derive_child!(0, false)
    |> PrivateKey.serialize()
  end

  defp from_derivation_path(private_key, derivation_path) do
    private_key
    |> PrivateKey.from_derivation_path!(derivation_path)
    |> PrivateKey.serialize()
  end
end
