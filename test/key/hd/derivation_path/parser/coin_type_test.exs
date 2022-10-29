defmodule BitcoinLib.Key.HD.DerivationPath.Parser.CoinTypeTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.DerivationPath.Parser.CoinType

  alias BitcoinLib.Key.HD.DerivationPath.Parser.CoinType

  test "derivation path extraction of an non-hardened coin type" do
    derivation_path = ["1", "2", "3", "4"]

    {:error, message} =
      derivation_path
      |> CoinType.extract()

    assert message == "coin type must be a hardened value"
  end

  test "derivation path extraction of an empty coin type" do
    derivation_path = []

    result =
      derivation_path
      |> CoinType.extract()

    assert {:ok, nil, []} == result
  end
end
