defmodule BitcoinLib.Key.HD.FingerprintTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.Fingerprint

  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Key.HD.{Fingerprint}

  test "compute a private key fingerprint" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    fingerprint =
      private_key
      |> Fingerprint.compute()

    assert fingerprint == <<0x18C1259::32>>
  end

  test "append a private key fingerprint" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    new_private_key =
      private_key
      |> Fingerprint.append()

    assert %PrivateKey{
             fingerprint: <<0x18C1259::32>>,
             key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
             chain_code:
               <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
           } == new_private_key
  end

  test "compute a public key fingerprint" do
    public_key = %PublicKey{
      key: <<0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9::264>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    fingerprint =
      public_key
      |> Fingerprint.compute()

    assert fingerprint == <<0x18C1259::32>>
  end

  test "make sure public and private keys issue the same fingerprint" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    public_key = PublicKey.from_private_key(private_key)

    private_fingerprint = Fingerprint.compute(private_key)
    public_fingerprint = Fingerprint.compute(public_key)

    assert private_fingerprint == public_fingerprint
  end
end
