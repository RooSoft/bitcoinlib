defmodule BitcoinLib.Key.HD.DerivationPathTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.HD.DerivationPath

  alias BitcoinLib.Key.HD.DerivationPath

  test "can parse a basic derivation path" do
    path = "m / 44' / 0' / 0' / 0 / 0"

    result =
      path
      |> DerivationPath.parse()

    %{
      purpose: %{hardened?: true, value: 44},
      coin_type: %{hardened?: true, value: 0},
      account: %{hardened?: true, value: 0},
      change: %{hardened?: false, value: 0},
      address_index: %{hardened?: false, value: 0}
    } = result
  end
end
