defmodule BitcoinLib.Key.AddressTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.Address

  alias BitcoinLib.Key.Address
  alias BitcoinLib.Key.PublicKey

  test "generate a testnet bech32 address" do
    public_key = %PublicKey{
      key: <<0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC::264>>
    }

    address = Address.from_public_key(public_key, :bech32, :testnet)

    assert "tb1qa5gyew808tdta3wjh6qh3jvcglukjsnfzfm4w0" == address
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

  test "generate a P2PKH from a public key hash" do
    public_key_hash = <<0x6AE201797DE3FA7D1D95510F50C1A9C50CE4CC36::160>>

    address =
      public_key_hash
      |> Address.from_public_key_hash()

    assert address == "1Ak9NVPmwCHEpsSWvM6cNRC7dsYniRmwMG"
  end

  test "generate a P2SH from a public key hash" do
    script_hash = <<0x6AE201797DE3FA7D1D95510F50C1A9C50CE4CC36::160>>

    address =
      script_hash
      |> Address.from_script_hash()

    assert address == "3BSAJ2tDV6bcv38x3SmCo3Z3nPqWHYxcM9"
  end

  test "make sure default addresses are P2SH" do
    script_hash = <<0x6AE201797DE3FA7D1D95510F50C1A9C50CE4CC36::160>>

    address =
      script_hash
      |> Address.from_script_hash()

    assert address == "3BSAJ2tDV6bcv38x3SmCo3Z3nPqWHYxcM9"
  end

  test "create a P2PKH testnet address from a public key hash" do
    public_key_hash = <<0x93CE48570B55C42C2AF816AEABA06CFEE1224FAE::160>>

    p2pkh_testnet_address =
      public_key_hash
      |> BitcoinLib.Key.Address.from_public_key_hash(:testnet)

    assert "mtzUk1zTJzTdyC8Pz6PPPyCHTEL5RLVyDJ" = p2pkh_testnet_address
  end

  test "create a P2SH testnet address from a script hash" do
    script_hash = <<0x93CE48570B55C42C2AF816AEABA06CFEE1224FAE::160>>

    p2sh_testnet_address =
      script_hash
      |> BitcoinLib.Key.Address.from_script_hash(:testnet)

    assert "2N6ikSFKwfKr7V2ym4khUcdL9x7EFrsvdWR" = p2sh_testnet_address
  end

  test "destructure an address" do
    address = "mtzUk1zTJzTdyC8Pz6PPPyCHTEL5RLVyDJ"

    {:ok, public_key_hash, :p2pkh, :testnet} =
      address
      |> Address.destructure()

    assert <<_::160>> = public_key_hash
  end

  test "test a valid P2PKH mainnet address" do
    address = "1Po1oWkD2LmodfkBYiAktwh76vkF93LKnh"

    valid? =
      address
      |> Address.valid?()

    assert valid?
  end

  test "test a invalid P2PKH mainnet address" do
    address = "1Po1oWkD2LmodfkBYiAktwh76vkF93LKnH"

    valid? =
      address
      |> Address.valid?()

    assert !valid?
  end

  test "test a valid P2PKH testnet address" do
    address = "mtzUk1zTJzTdyC8Pz6PPPyCHTEL5RLVyDJ"

    valid? =
      address
      |> Address.valid?()

    assert valid?
  end

  test "test a invalid P2PKH testnet address" do
    address = "mtzUk1zTJzTdyC8Pz6PPPyCHTEL5RLVyDj"

    valid? =
      address
      |> Address.valid?()

    assert !valid?
  end
end
