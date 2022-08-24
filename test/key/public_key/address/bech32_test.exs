defmodule BitcoinLib.Key.PublicKey.Address.Bech32Test do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.PublicKey.Address.Bech32

  alias BitcoinLib.Key.PublicKey
  alias BitcoinLib.Key.PublicKey.Address.Bech32

  test "create a bech32 address from an extended public key" do
    public_key = %PublicKey{
      key: <<0x0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798::264>>,
      chain_code: 0
    }

    address =
      public_key
      |> Bech32.from_public_key()

    assert "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4" == address
  end

  test "create a testnet bech32 address from an extended public key" do
    public_key = %PublicKey{
      key: <<0x0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798::264>>,
      chain_code: 0
    }

    address =
      public_key
      |> Bech32.from_public_key(:testnet)

    assert "tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty" == address
  end
end
