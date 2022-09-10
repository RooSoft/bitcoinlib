defmodule BitcoinLib.Key.PublicKey.AddressTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.PublicKey.Address

  alias BitcoinLib.Key.PublicKey.Address
  alias BitcoinLib.Key.PublicKey

  test "generate a testnet bech32 address" do
    public_key = %PublicKey{
      key: <<0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC::264>>
    }

    address = Address.from_public_key(public_key, :bech32, :testnet)

    assert "tc1qa5gyew808tdta3wjh6qh3jvcglukjsnfvepz4d" == address
  end
end
