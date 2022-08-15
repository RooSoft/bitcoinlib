defmodule BitcoinLib.Key.HD.ExtendedPublic.Address.P2SHTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPublic.Address.P2SH

  alias BitcoinLib.Key.HD.ExtendedPublic
  alias BitcoinLib.Key.HD.ExtendedPublic.Address.P2SH

  test "create a P2SH-P2WPKH address from an extended public key" do
    public_key = %ExtendedPublic{
      key: <<0x02D0DE0AAEAEFAD02B8BDC8A01A1B8B11C696BD3D66A2C5F10780D95B7DF42645C::264>>,
      chain_code: 0
    }

    address =
      public_key
      |> P2SH.from_extended_public_key()

    assert "3D9iyFHi1Zs9KoyynUfrL82rGhJfYTfSG4" == address
  end

  test "create a P2SH-P2WPKH address from an extended public key on the testnet network" do
    public_key = %ExtendedPublic{
      key: <<0x02D0DE0AAEAEFAD02B8BDC8A01A1B8B11C696BD3D66A2C5F10780D95B7DF42645C::264>>,
      chain_code: 0
    }

    address =
      public_key
      |> P2SH.from_extended_public_key(:testnet)

    assert "2N4hw2zDjd2NVXbcXTcHix527V3WqLjqqve" == address
  end
end
