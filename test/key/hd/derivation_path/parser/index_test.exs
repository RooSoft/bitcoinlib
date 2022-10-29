defmodule BitcoinLib.Key.HD.DerivationPath.Parser.IndexTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.DerivationPath.Parser.Index

  alias BitcoinLib.Key.HD.DerivationPath.Parser.Index

  test "derivation path extraction of an hardened index" do
    derivation_path = ["4'"]

    {:error, message} =
      derivation_path
      |> Index.extract()

    assert message == "account number must NOT be a hardened value"
  end

  test "derivation path extraction of an empty index" do
    derivation_path = []

    result =
      derivation_path
      |> Index.extract()

    assert {:ok, nil} == result
  end
end
