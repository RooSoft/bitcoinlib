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
             coin_type: :bitcoin,
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
             coin_type: :bitcoin,
             account: %{hardened?: true, value: 0},
             change: %{hardened?: false, value: 0},
             address_index: %{hardened?: false, value: 0}
           } = result
  end

  test "a bip49 derivation path" do
    path = "m/49'/0'/0'/0/0"

    {:ok, result} =
      path
      |> DerivationPath.parse()

    assert %{
             purpose: :bip49
           } = result
  end

  test "a bip84 derivation path" do
    path = "m/84'/0'/0'/0/0"

    {:ok, result} =
      path
      |> DerivationPath.parse()

    assert %{
             purpose: :bip84
           } = result
  end

  test "a derivation path with an invalid purpose" do
    path = "m/88'/0'/0'/0/0"

    {:error, result} =
      path
      |> DerivationPath.parse()

    assert "Invalid purpose" = result
  end

  test "valid derivation path with an uppper case M" do
    path = "M / 44' / 0' / 0' / 0 / 0"

    {:ok, result} =
      path
      |> DerivationPath.parse()

    assert %{
             purpose: :bip44,
             coin_type: :bitcoin,
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

  test "derivation path with testnet coin type" do
    path = "m/44'/1'/0'/0/0"

    {:ok, result} =
      path
      |> DerivationPath.parse()

    assert %{coin_type: :bitcoin_testnet} = result
  end

  test "derivation path with invalid coin type" do
    path = "m/44'/2'/0'/0/0"

    {:error, result} =
      path
      |> DerivationPath.parse()

    assert "Invalid coin type" = result
  end
end
