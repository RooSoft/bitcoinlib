defmodule BitcoinLib.Key.HD.DerivationPath.Parser.TypeTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.DerivationPath.Parser.Type

  test "derivation path extraction of an invalid type" do
    derivation_path = ["x", "0", "1", "2", "3", "4"]

    {:error, message} =
      derivation_path
      |> BitcoinLib.Key.HD.DerivationPath.Parser.Type.extract()

    assert message =~ "is not a valid type"
  end
end
