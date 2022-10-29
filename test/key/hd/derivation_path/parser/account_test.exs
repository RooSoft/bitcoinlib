defmodule BitcoinLib.Key.HD.DerivationPath.Parser.AccountTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.DerivationPath.Parser.Account

  alias BitcoinLib.Key.HD.DerivationPath.Parser.Account

  test "derivation path extraction of an non-hardened account" do
    derivation_path = ["2", "3", "4"]

    {:error, message} =
      derivation_path
      |> Account.extract()

    assert message == "account number must be a hardened value"
  end

  test "derivation path extraction of an empty account number" do
    derivation_path = []

    result =
      derivation_path
      |> Account.extract()

    assert {:ok, nil, []} == result
  end
end
