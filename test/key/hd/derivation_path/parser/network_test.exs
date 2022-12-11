defmodule BitcoinLib.Key.HD.DerivationPath.Parser.NetworkTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.DerivationPath.Parser.Network

  alias BitcoinLib.Key.HD.DerivationPath.Parser.Network

  test "derivation path extraction of an non-hardened network" do
    derivation_path = ["1", "2", "3", "4"]

    {:error, message} =
      derivation_path
      |> Network.extract()

    assert message == "network must be a hardened value"
  end

  test "derivation path extraction of an invalid hardened network" do
    derivation_path = ["10'", "2", "3", "4"]

    {:error, message} =
      derivation_path
      |> Network.extract()

    assert message =~ "invalid network"
  end

  test "derivation path extraction of an empty network" do
    derivation_path = []

    result =
      derivation_path
      |> Network.extract()

    assert {:ok, nil, []} == result
  end
end
