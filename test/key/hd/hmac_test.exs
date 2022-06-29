defmodule BitcoinLib.Key.HD.HmacTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.Hmac

  alias BitcoinLib.Key.HD.{Hmac, ExtendedPrivate}

  test "compute HMAC on a private key" do
    private_key = %BitcoinLib.Key.HD.ExtendedPrivate{
      key: 0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35,
      chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508
    }

    hmac =
      private_key
      |> Hmac.compute(0)

    assert {
             0x6539AE80B3618C22F5F8CC4171D04835570BDA8DB11B5BF1779AFAE7EC7C79C3,
             0xD323F1BE5AF39A2D2F08F5E8F664633849653DBE329802E9847CFC85F8D7B52A
           } == hmac
  end
end
