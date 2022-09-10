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

  test "generate a testnet P2PKH address" do
    public_key = %PublicKey{
      key: <<0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC::264>>
    }

    address = Address.from_public_key(public_key, :p2pkh, :testnet)

    assert "n38Ry3Juscr54rDkVFofQM5sejEDiLio4u" == address
  end

  test "generate a testnet P2SH address" do
    public_key = %PublicKey{
      key: <<0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC::264>>
    }

    address = Address.from_public_key(public_key, :p2sh, :testnet)

    assert "2N2zcHHKL9G8dAFGZa3R7KeKfW8CK3UPzcV" == address
  end

  test "generate a bech32 address" do
    public_key = %PublicKey{
      key: <<0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC::264>>
    }

    address = Address.from_public_key(public_key, :bech32, :mainnet)

    assert "bc1qa5gyew808tdta3wjh6qh3jvcglukjsnfg0qx4u" == address
  end

  test "generate a P2PKH address" do
    public_key = %PublicKey{
      key: <<0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC::264>>
    }

    address = Address.from_public_key(public_key, :p2pkh, :mainnet)

    assert "1NcUfzDw4bQpHjk8mgqHaRsYnjdWqSYsYt" == address
  end

  test "generate a P2SH address" do
    public_key = %PublicKey{
      key: <<0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC::264>>
    }

    address = Address.from_public_key(public_key, :p2sh, :mainnet)

    assert "3BSQDYPJXodGxTe1tuoEhhLQHmz9BrRjv2" == address
  end
end
