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
end
