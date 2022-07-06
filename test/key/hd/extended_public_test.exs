defmodule BitcoinLib.Key.HD.ExtendedPublicTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPublic

  alias BitcoinLib.Key.HD.{DerivationPath, ExtendedPrivate, ExtendedPublic}

  test "derives an extended public key from an extended private key" do
    private_key = %ExtendedPrivate{
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

    {:ok, serialized} = ExtendedPublic.serialize(public_key)

    assert "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8" ==
             serialized
  end

  test "serialize a master public key using ypub" do
    public_key = %ExtendedPublic{
      key: 0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2,
      chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508
    }

    {:ok, serialized} = ExtendedPublic.serialize(public_key, :ypub)

    assert "ypub6QqdH2c5z7967BioGSfAWFHM1EHzHPBZK7wrND3ZpEWFtzmCqvsD1bgpaE6pSAPkiSKhkuWPCJV6mZTSNMd2tK8xYTcJ48585pZecmSUzWp" ==
             serialized
  end

  test "serialize a master public key using zpub" do
    public_key = %ExtendedPublic{
      key: 0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2,
      chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508
    }

    {:ok, serialized} = ExtendedPublic.serialize(public_key, :zpub)

    assert "zpub6jftahH18ngZxUuv6oSniLNrBCSSE1B4EEU59bwTCEt8x6aS6b2mdfLxbS4QS53g85SWWP6wexqeer516433gYpZQoJie2tcMYdJ1SYYYAL" ==
             serialized
  end

  test "deserialize a xpub into a master public key" do
    serialized =
      "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"

    {:ok, public_key} =
      serialized
      |> ExtendedPublic.deserialize()

    assert %ExtendedPublic{
             fingerprint: 0x3442193E,
             key: 0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2,
             chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508
           } == public_key
  end

  test "deserialize a ypub into a master public key" do
    serialized =
      "ypub6WwZCtcXYyyL6GHQrB8pnaHRNCaAWhuQkQraCKUk7qpF4JmVgwMAvaCu9m6o9nAeyFRqw6xyZxG7CDf16GMHFYbtw8KCtNsgkRoRs7YFJf9"

    {:ok, public_key} =
      serialized
      |> ExtendedPublic.deserialize()

    assert %ExtendedPublic{
             chain_code: 0xA2C4FF37835B5F1C50969101C9A35AFAD2AFEC6C0AB8D8D49ADDA9E232488AD4,
             depth: 3,
             fingerprint: 0x9A6A4CDE,
             index: 0x80000000,
             key: 0x3362BF7EE2FA92C4DB0D125108170EEE65CBB0FB5269A5CAB02703B543052470A,
             parent_fingerprint: 0x3E374C4A
           } == public_key
  end

  test "serialize and deserialize an xpub key and make sure they're the same" do
    original_public_key = %ExtendedPublic{
      fingerprint: 0x3442193E,
      key: 0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2,
      chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508
    }

    {:ok, serialized} = ExtendedPublic.serialize(original_public_key)

    {:ok, deserialized_public_key} = ExtendedPublic.deserialize(serialized)

    assert deserialized_public_key == original_public_key
  end

  test "serialize and deserialize a ypub key and make sure they're the same" do
    original_public_key = %ExtendedPublic{
      fingerprint: 0x3442193E,
      key: 0x339A36013301597DAEF41FBE593A02CC513D0B55527EC2DF1050E2E8FF49C85C2,
      chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508
    }

    {:ok, serialized} = ExtendedPublic.serialize(original_public_key, :ypub)

    {:ok, deserialized_public_key} = ExtendedPublic.deserialize(serialized)

    assert deserialized_public_key == original_public_key
  end

  test "derive the first child" do
    public_key = %ExtendedPublic{
      key: 0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    index = 0

    result = ExtendedPublic.derive_child(public_key, index)

    assert {
             :ok,
             %ExtendedPublic{
               key: 0x30204D3503024160E8303C0042930EA92A9D671DE9AA139C1867353F6B6664E59,
               chain_code: 0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31,
               depth: 1,
               index: 0,
               parent_fingerprint: 0x18C1259,
               fingerprint: 0x9680603F
             }
           } == result
  end

  test "derive the first child, without error checking" do
    public_key = %ExtendedPublic{
      key: 0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    index = 0

    child = ExtendedPublic.derive_child!(public_key, index)

    assert %ExtendedPublic{
             key: 0x30204D3503024160E8303C0042930EA92A9D671DE9AA139C1867353F6B6664E59,
             chain_code: 0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31,
             depth: 1,
             index: 0,
             parent_fingerprint: 0x18C1259,
             fingerprint: 0x9680603F
           } == child
  end

  test "derive a public key from a derivation path" do
    public_key = %ExtendedPublic{
      key: 0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    {:ok, derivation_path} = DerivationPath.parse("M/44'/0'/0'/0/0")

    derived_key = ExtendedPublic.from_derivation_path(public_key, derivation_path)

    assert {
             :ok,
             %ExtendedPublic{
               key: 0x29DCAFD0D7D67B13657CC9EE7C8976E141F20F0684BF3FC83CAF068E74186BCDC,
               chain_code: 0x162EEE68F7C3823CAF8BD2615A4A33633673CAAB66FF6F338FB0653FC59D462D,
               depth: 5,
               index: 0,
               parent_fingerprint: 0xCA2A5281
             }
           } = derived_key
  end

  @doc """
  Example straight from this forum page: https://bitcointalk.org/index.php?topic=5229211.msg53930214#msg53930214
  """
  test "create the first receive address of a public_key" do
    public_key = %ExtendedPublic{
      key: 0x02D0DE0AAEAEFAD02B8BDC8A01A1B8B11C696BD3D66A2C5F10780D95B7DF42645C,
      chain_code: 0
    }

    address =
      public_key
      |> ExtendedPublic.to_address(:p2sh)

    assert address == "3D9iyFHi1Zs9KoyynUfrL82rGhJfYTfSG4"
  end

  @doc """
  Source: https://bitcointalk.org/index.php?topic=4992632.0
  """
  test "create a bech32 address" do
    public_key = %ExtendedPublic{
      key: 0x0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
      chain_code: 0
    }

    address =
      public_key
      |> ExtendedPublic.to_address(:bech32)

    assert address == "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4"
  end

  @doc """
  With https://www.npmjs.com/package/@swan-bitcoin/xpub-cli installed, run this command and get the address below

  `xpub derive ypub6WwZCtcXYyyL6GHQrB8pnaHRNCaAWhuQkQraCKUk7qpF4JmVgwMAvaCu9m6o9nAeyFRqw6xyZxG7CDf16GMHFYbtw8KCtNsgkRoRs7YFJf9 -c0 --purpose p2sh`
  """
  test "create the first receive address of a specific ypub" do
    public_key =
      "ypub6WwZCtcXYyyL6GHQrB8pnaHRNCaAWhuQkQraCKUk7qpF4JmVgwMAvaCu9m6o9nAeyFRqw6xyZxG7CDf16GMHFYbtw8KCtNsgkRoRs7YFJf9"
      |> ExtendedPublic.deserialize!()
      |> ExtendedPublic.derive_child!(0)
      |> ExtendedPublic.derive_child!(0)

    address =
      public_key
      |> ExtendedPublic.to_address(:p2sh)

    assert address == "3Bq68AEDGwkMbVDuzNF2C1CsePJMfckqzG"
  end
end
