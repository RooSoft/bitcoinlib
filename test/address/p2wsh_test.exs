defmodule BitcoinLib.Address.P2WSHTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Address.P2WSH

  alias BitcoinLib.Address.P2WSH

  test "create a P2WSH address from an script hash" do
    key_hash = <<0x6ff04018aff3bd320c89e2e8c9d4274e6b0e780975cd364810239ecc7bd8138a::256>>

    address =
      key_hash
      |> P2WSH.from_script_hash()

    assert "bc1qdlcyqx907w7nyryfut5vn4p8fe4su7qfwhxnvjqsyw0vc77czw9q6d8zkl" == address
  end

  test "create a P2WSH address from an script hash on the testnet network" do
    key_hash = <<0x6ff04018aff3bd320c89e2e8c9d4274e6b0e780975cd364810239ecc7bd8138a::256>>

    address =
      key_hash
      |> P2WSH.from_script_hash(:testnet)

    assert "tb1qdlcyqx907w7nyryfut5vn4p8fe4su7qfwhxnvjqsyw0vc77czw9qd93dvs" == address
  end
end
