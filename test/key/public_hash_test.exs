defmodule BitcoinLib.Key.PublicHashTest do
  use ExUnit.Case

  alias BitcoinLib.Key.PublicHash

  test "creates a public key hash from a public key" do
    public_key = "0250863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b2352"

    hash =
      public_key
      |> PublicHash.from_public_key()

    assert hash == "93ce48570b55c42c2af816aeaba06cfee1224fae"
  end
end
