defmodule BitcoinLib.Key.HD.ExtendedPublic.Address.Bech32Test do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPublic.Address.Bech32

  alias BitcoinLib.Key.HD.ExtendedPublic
  alias BitcoinLib.Key.HD.ExtendedPublic.Address.Bech32

  test "create a bech32 address from an extended public key" do
    public_key = %ExtendedPublic{
      key: 0x0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
      chain_code: 0
    }

    address =
      public_key
      |> Bech32.from_extended_public_key()

    assert "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4" == address
  end
end
