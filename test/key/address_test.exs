defmodule BitcoinLib.Key.AddressTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.Address

  alias BitcoinLib.Key.Address

  test "generate a P2PKH from a public key hash" do
    public_key_hash = "6ae201797de3fa7d1d95510f50c1a9c50ce4cc36"

    address =
      public_key_hash
      |> Address.from_public_key_hash()

    assert address == "1Ak9NVPmwCHEpsSWvM6cNRC7dsYniRmwMG"
  end
end
