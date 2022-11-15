defmodule BitcoinLib.Address.P2WPKHTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Address.P2WPKH

  alias BitcoinLib.Address.P2WPKH

  test "create a P2WPKH address from a key hash" do
    key_hash = <<0x13BFFF2D6DD02B8837F156C6F9FE0EA7363DF795::160>>

    address =
      key_hash
      |> P2WPKH.from_key_hash()

    assert "bc1qzwll7ttd6q4csdl32mr0nlsw5umrmau4es49qe" == address
  end

  test "create a P2WPKH address from a key hash on the testnet network" do
    key_hash = <<0x13BFFF2D6DD02B8837F156C6F9FE0EA7363DF795::160>>

    address =
      key_hash
      |> P2WPKH.from_key_hash(:testnet)

    assert "tb1qzwll7ttd6q4csdl32mr0nlsw5umrmau4nkwkm2" == address
  end
end
