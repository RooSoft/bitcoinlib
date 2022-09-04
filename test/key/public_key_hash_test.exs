defmodule BitcoinLib.Key.PublicKeyHashTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.PublicKeyHash

  alias BitcoinLib.Key.{PublicKey, PublicKeyHash}

  test "creates a public key hash from a public key" do
    public_key = %PublicKey{
      key: <<0x02B4632D08485FF1DF2DB55B9DAFD23347D1C47A457072A1E87BE26896549A8737::264>>
    }

    hash =
      public_key
      |> PublicKeyHash.from_public_key()

    assert hash == <<0x93CE48570B55C42C2AF816AEABA06CFEE1224FAE::160>>
  end

  test "convert address to public key hash" do
    address = "mwYKDe7uJcgqyVHJAPURddeZvM5zBVQj5L"

    {:ok, public_key_hash} = PublicKeyHash.from_address(address)

    assert <<0xafc3e518577316386188af748a816cd14ce333f2::160>> == public_key_hash
  end
end
