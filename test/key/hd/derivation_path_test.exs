defmodule BitcoinLib.Key.HD.DerivationPathTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.HD.DerivationPath

  alias BitcoinLib.Key.HD.DerivationPath

  test "can parse a basic derivation path with a lowercase m" do
    path = "m / 44' / 0' / 0' / 0 / 0"

    {:ok, result} =
      path
      |> DerivationPath.parse()

    assert %{
             purpose: :bip44,
             coin_type: %{hardened?: true, value: 0},
             account: %{hardened?: true, value: 0},
             change: %{hardened?: false, value: 0},
             address_index: %{hardened?: false, value: 0}
           } = result
  end

  test "a compact derivation path" do
    path = "m/44'/0'/0'/0/0"

    {:ok, result} =
      path
      |> DerivationPath.parse()

    assert %{
             purpose: :bip44,
             coin_type: %{hardened?: true, value: 0},
             account: %{hardened?: true, value: 0},
             change: %{hardened?: false, value: 0},
             address_index: %{hardened?: false, value: 0}
           } = result
  end

  test "valid derivation path with an uppper case M" do
    path = "M / 44' / 0' / 0' / 0 / 0"

    {:ok, result} =
      path
      |> DerivationPath.parse()

    assert %{
             purpose: :bip44,
             coin_type: %{hardened?: true, value: 0},
             account: %{hardened?: true, value: 0},
             change: %{hardened?: false, value: 0},
             address_index: %{hardened?: false, value: 0}
           } = result
  end

  test "cause an error with an empty derivation path" do
    path = ""

    {:error, result} =
      path
      |> DerivationPath.parse()

    assert "Invalid derivation path" = result
  end

  test "derivation path with a missing slash and value" do
    path = "m / 44' / 0' / 0' / 0"

    {:error, result} =
      path
      |> DerivationPath.parse()

    assert "Invalid derivation path" = result
  end

  test "derivation path with missing values but all slashes present" do
    path = "m / 44' / 0' / 0' ///"

    {:error, result} =
      path
      |> DerivationPath.parse()

    assert "Invalid derivation path" = result
  end

  test "derivation path with double quote" do
    path = "m / 44'' / 0' / 0' / 0 / 0"

    {:error, result} =
      path
      |> DerivationPath.parse()

    assert "Invalid derivation path" = result
  end

  test "derivation path with invalid characters" do
    path = "m / 44'xxx / 0' / 0' / 0 / 0"

    {:error, result} =
      path
      |> DerivationPath.parse()

    assert "Invalid derivation path" = result
  end
end
