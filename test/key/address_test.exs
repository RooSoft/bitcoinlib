defmodule BitcoinLib.Key.AddressTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.Address

  alias BitcoinLib.Key.Address

  test "generate a P2PKH from a public key hash" do
    public_key_hash = 0x6AE201797DE3FA7D1D95510F50C1A9C50CE4CC36

    address =
      public_key_hash
      |> Address.from_public_key_hash(:p2pkh)

    assert address == "1Ak9NVPmwCHEpsSWvM6cNRC7dsYniRmwMG"
  end

  test "generate a P2SH from a public key hash" do
    public_key_hash = 0x6AE201797DE3FA7D1D95510F50C1A9C50CE4CC36

    address =
      public_key_hash
      |> Address.from_public_key_hash(:p2sh)

    assert address == "3BSAJ2tDV6bcv38x3SmCo3Z3nPqWHYxcM9"
  end

  test "make sure default addresses are P2SH" do
    public_key_hash = 0x6AE201797DE3FA7D1D95510F50C1A9C50CE4CC36

    address =
      public_key_hash
      |> Address.from_public_key_hash()

    assert address == "3BSAJ2tDV6bcv38x3SmCo3Z3nPqWHYxcM9"
  end
end
