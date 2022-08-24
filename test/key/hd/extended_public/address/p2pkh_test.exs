defmodule BitcoinLib.Key.HD.ExtendedPublic.Address.P2PKHTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPublic.Address.P2PKH

  alias BitcoinLib.Key.PublicKey
  alias BitcoinLib.Key.HD.ExtendedPublic.Address.P2PKH

  test "create a P2PKH address from an extended public key" do
    public_key = %PublicKey{
      key: <<0x02D0DE0AAEAEFAD02B8BDC8A01A1B8B11C696BD3D66A2C5F10780D95B7DF42645C::264>>,
      chain_code: 0
    }

    address =
      public_key
      |> P2PKH.from_public_key()

    assert "1LoVGDgRs9hTfTNJNuXKSpywcbdvwRXpmK" == address
  end

  test "create a P2PKH address from an extended public key on the testnet network" do
    public_key = %PublicKey{
      key: <<0x02D0DE0AAEAEFAD02B8BDC8A01A1B8B11C696BD3D66A2C5F10780D95B7DF42645C::264>>,
      chain_code: 0
    }

    address =
      public_key
      |> P2PKH.from_public_key(:testnet)

    assert "n1KSZGmQgB8iSZqv6UVhGkCGUbEdw8Lm3Q" == address
  end
end
