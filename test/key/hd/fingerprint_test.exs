defmodule BitcoinLib.Key.HD.FingerprintTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.Fingerprint

  alias BitcoinLib.Key.HD.{Fingerprint, ExtendedPrivate}

  test "compute a private key fingerprint" do
    private_key = %ExtendedPrivate{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    fingerprint =
      private_key
      |> Fingerprint.compute()

    assert fingerprint == 0x18C1259
  end
end
