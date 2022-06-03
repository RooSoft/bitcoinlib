defmodule BitcoinLib.Key.PublicHashTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.PublicHash

  alias BitcoinLib.Key.PublicHash

  test "creates a public key hash from a public key" do
    public_key = "02b4632d08485ff1df2db55b9dafd23347d1c47a457072a1e87be26896549a8737"

    hash =
      public_key
      |> PublicHash.from_public_key()

    assert hash == "93ce48570b55c42c2af816aeaba06cfee1224fae"
  end
end
