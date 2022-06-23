defmodule BitcoinLib.Test.Integration.Bip32.ChildVsDerivationPathTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.HD.{ExtendedPrivate, MnemonicSeed}

  test "compare values of a child derived private key versus the same with a derivation path" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> MnemonicSeed.to_seed()
      |> ExtendedPrivate.from_seed()

    manually_derived_child_private_key = derive_manually(private_key)
    from_derivation_path_private_key = from_derivation_path(private_key, "m/44'/0'/0'/1/0")

    assert manually_derived_child_private_key == from_derivation_path_private_key
  end

  defp derive_manually(private_key) do
    private_key
    |> ExtendedPrivate.derive_child(44, true)
    |> elem(1)
    |> ExtendedPrivate.derive_child(0, true)
    |> elem(1)
    |> ExtendedPrivate.derive_child(0, true)
    |> elem(1)
    |> ExtendedPrivate.derive_child(1, false)
    |> elem(1)
    |> ExtendedPrivate.derive_child(0, false)
    |> elem(1)
    |> ExtendedPrivate.serialize()
  end

  defp from_derivation_path(private_key, derivation_path) do
    private_key
    |> ExtendedPrivate.from_derivation_path(derivation_path)
    |> elem(1)
    |> ExtendedPrivate.serialize()
  end
end
