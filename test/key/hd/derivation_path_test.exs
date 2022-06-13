defmodule BitcoinLib.Key.HD.DerivationPathTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.HD.DerivationPath

  alias BitcoinLib.Key.HD.DerivationPath

  test "can parse a basic derivation path" do
    path = "m / 44' / 0' / 0' / 0 / 0"

    {:ok, result} =
      path
      |> DerivationPath.parse()

    assert %{
             purpose: %{hardened?: true, value: 44},
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

    assert "Some parameters are missing" = result
  end

  test "derivation path with a missing value" do
    path = "m / 44' / 0' / 0' / 0"

    {:error, result} =
      path
      |> DerivationPath.parse()

    assert "Some parameters are missing" = result
  end
end
