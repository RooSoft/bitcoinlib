defmodule BitcoinLib.Key.HD.DerivationPath.Parser.ChangeTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.DerivationPath.Parser.Change

  alias BitcoinLib.Key.HD.DerivationPath.Parser.Change

  test "derivation path extraction of a hardened change chain" do
    derivation_path = ["3'", "4"]

    {:error, message} =
      derivation_path
      |> Change.extract()

    assert message == "change chain must NOT be a hardened value"
  end

  test "derivation path extraction of an invalid change chain" do
    derivation_path = ["3", "4"]

    {:error, message} =
      derivation_path
      |> Change.extract()

    assert message =~ "is not a valid change chain"
  end

  test "derivation path extraction of an empty change chain" do
    derivation_path = []

    result =
      derivation_path
      |> Change.extract()

    assert {:ok, nil, []} == result
  end
end
