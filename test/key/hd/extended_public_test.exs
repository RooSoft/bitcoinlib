defmodule BitcoinLib.Key.HD.ExtendedPublicTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPublic

  alias BitcoinLib.Key.HD.ExtendedPublic

  test "derives an extended public key from an extended private key" do
    private_key = %BitcoinLib.Key.HD.ExtendedPrivate{
      key: 0x081549973BAFBBA825B31BCC402A3C4ED8E3185C2F3A31C75E55F423E9629AA3,
      chain_code: 0x1D7D2A4C940BE028B945302AD79DD2CE2AFE5ED55E1A2937A5AF57F8401E73DD
    }

    public_key =
      private_key
      |> ExtendedPublic.from_private_key()

    assert %ExtendedPublic{
             key: 0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC,
             chain_code: 0x1D7D2A4C940BE028B945302AD79DD2CE2AFE5ED55E1A2937A5AF57F8401E73DD
           } = public_key
  end

  test "serialize a master public key" do
    public_key = %ExtendedPublic{
      key: 0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2,
      chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508
    }

    serialized = BitcoinLib.Key.HD.ExtendedPublic.serialize(public_key)

    assert "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8" ==
             serialized
  end

  test "derive the first child" do
    public_key = %BitcoinLib.Key.HD.ExtendedPublic{
      key: 0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    index = 0

    result = BitcoinLib.Key.HD.ExtendedPublic.derive_child(public_key, index)

    assert {
      :ok,
      %BitcoinLib.Key.HD.ExtendedPublic{
        key: 0x30204D3503024160E8303C0042930EA92A9D671DE9AA139C1867353F6B6664E59,
        chain_code: 0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31,
        depth: 1,
        index: 0,
        parent_fingerprint: 0x18C1259
      }
    } == result
  end

  test "derive the first child, without error checking" do
    public_key = %BitcoinLib.Key.HD.ExtendedPublic{
      key: 0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    index = 0

    child = BitcoinLib.Key.HD.ExtendedPublic.derive_child!(public_key, index)

    assert %BitcoinLib.Key.HD.ExtendedPublic{
      key: 0x30204D3503024160E8303C0042930EA92A9D671DE9AA139C1867353F6B6664E59,
      chain_code: 0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31,
      depth: 1,
      index: 0,
      parent_fingerprint: 0x18C1259
    } == child
  end
end
