defmodule BitcoinLib.Key.HD.DerivationPath.Parser.PurposeTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.DerivationPath.Parser.Purpose

  alias BitcoinLib.Key.HD.DerivationPath.Parser.Purpose

  test "derivation path extraction of an non-hardened purpose" do
    derivation_path = ["0", "1", "2", "3", "4"]

    {:error, message} =
      derivation_path
      |> Purpose.extract()

    assert message == "purpose must be a hardened value"
  end

  test "derivation path extraction of an invalid purpose" do
    derivation_path = ["0'", "1", "2", "3", "4"]

    {:error, message} =
      derivation_path
      |> Purpose.extract()

    assert message =~ "is an invalid purpose"
  end

  test "derivation path extraction of an empty purpose" do
    derivation_path = []

    result =
      derivation_path
      |> Purpose.extract()

    assert {:ok, nil, []} == result
  end
end
