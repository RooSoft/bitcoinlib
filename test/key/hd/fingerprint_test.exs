defmodule BitcoinLib.Key.HD.FingerprintTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.Fingerprint

  alias BitcoinLib.Key.HD.{Fingerprint, ExtendedPublic, ExtendedPrivate}

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

  test "append a private key fingerprint" do
    private_key = %ExtendedPrivate{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    new_private_key =
      private_key
      |> Fingerprint.append()

    assert %ExtendedPrivate{
             fingerprint: 0x18C1259,
             key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
             chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
           } == new_private_key
  end

  test "compute a public key fingerprint" do
    public_key = %ExtendedPublic{
      key: 0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    fingerprint =
      public_key
      |> Fingerprint.compute()

    assert fingerprint == 0x18C1259
  end

  test "make sure public and private keys issue the same fingerprint" do
    private_key = %ExtendedPrivate{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    public_key = ExtendedPublic.from_private_key(private_key)

    private_fingerprint = Fingerprint.compute(private_key)
    public_fingerprint = Fingerprint.compute(public_key)

    assert private_fingerprint == public_fingerprint
  end
end
