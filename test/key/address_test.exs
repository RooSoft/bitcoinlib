defmodule BitcoinLib.Key.AddressTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.Address

  alias BitcoinLib.Key.Address

  test "generate a P2PKH from a public key hash" do
    public_key_hash = <<0x6AE201797DE3FA7D1D95510F50C1A9C50CE4CC36::160>>

    address =
      public_key_hash
      |> Address.from_public_key_hash(:p2pkh)

    assert address == "1Ak9NVPmwCHEpsSWvM6cNRC7dsYniRmwMG"
  end

  test "generate a P2SH from a public key hash" do
    public_key_hash = <<0x6AE201797DE3FA7D1D95510F50C1A9C50CE4CC36::160>>

    address =
      public_key_hash
      |> Address.from_public_key_hash(:p2sh)

    assert address == "3BSAJ2tDV6bcv38x3SmCo3Z3nPqWHYxcM9"
  end

  test "make sure default addresses are P2SH" do
    public_key_hash = <<0x6AE201797DE3FA7D1D95510F50C1A9C50CE4CC36::160>>

    address =
      public_key_hash
      |> Address.from_public_key_hash()

    assert address == "3BSAJ2tDV6bcv38x3SmCo3Z3nPqWHYxcM9"
  end

  test "create a P2PKH testnet address from a public key hash" do
    public_key_hash = <<0x93CE48570B55C42C2AF816AEABA06CFEE1224FAE::160>>

    p2pkh_testnet_address =
      public_key_hash
      |> BitcoinLib.Key.Address.from_public_key_hash(:p2pkh, :testnet)

    assert "mtzUk1zTJzTdyC8Pz6PPPyCHTEL5RLVyDJ" = p2pkh_testnet_address
  end

  test "create a P2SH testnet address from a public key hash" do
    public_key_hash = <<0x93CE48570B55C42C2AF816AEABA06CFEE1224FAE::160>>

    p2pkh_testnet_address =
      public_key_hash
      |> BitcoinLib.Key.Address.from_public_key_hash(:p2sh, :testnet)

    assert "2N6ikSFKwfKr7V2ym4khUcdL9x7EFrsvdWR" = p2pkh_testnet_address
  end

  test "convert an address to a public key hash" do
    address = "mtzUk1zTJzTdyC8Pz6PPPyCHTEL5RLVyDJ"

    {:ok, public_key_hash, :p2pkh} =
      address
      |> Address.to_public_key_hash()

    assert <<_::160>> = public_key_hash
  end
end
