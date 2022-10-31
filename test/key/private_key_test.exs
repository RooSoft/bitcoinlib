defmodule BitcoinLib.Key.PrivateKeyTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.PrivateKey

  alias BitcoinLib.Key.PrivateKey
  alias BitcoinLib.Key.HD.{DerivationPath}

  test "creates a WIF from a private key" do
    private_key = %PrivateKey{
      key: <<0x6C7AB2F961A1BC3F13CDC08DC41C3F439ADEBD549A8EF1C089E81A5907376107::256>>
    }

    wif =
      private_key
      |> PrivateKey.to_wif()

    assert wif == "KzractrYn5gnDNVwBDy7sYhAkyMvX4WeYQpwyhCAUKDogJTzYsUc"
  end

  test "returns an extended private key from a seed" do
    seed =
      "67f93560761e20617de26e0cb84f7234aaf373ed2e66295c3d7397e6d7ebe882ea396d5d293808b0defd7edd2babd4c091ad942e6a9351e6d075a29d4df872af"

    extended_private_key =
      seed
      |> PrivateKey.from_seed()

    assert %PrivateKey{
             key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
             chain_code:
               <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
           } = extended_private_key
  end

  test "extract the master extended private key from a seed phrase" do
    # inspired by https://github.com/zyield/block_keys/blob/f5c28c885872e24e99d07fd6f1c1c967cd63ae3f/test/block_keys/ckd_test.exs#L84

    seed_phrase =
      "safe result wire cattle sauce luggage couple legend pause rather employ pear " <>
        "trigger live daring unlock music lyrics smoke mistake endorse kite obey siren"

    private_key =
      seed_phrase
      |> PrivateKey.from_seed_phrase()

    assert %PrivateKey{
             key: <<0x30A6B59CCCC924FC9FFD4AB08C5C01F0D6A4046797BB255D8919EB3E95C08871::256>>,
             chain_code:
               <<0xE08FCC54429E47AC55FEBD4DC9EDCCC88D292EB40AA3765AF3DA7178A14AA114::256>>,
             depth: 0,
             index: 0,
             fingerprint: <<0x1CF14AB4::32>>,
             parent_fingerprint: <<0::32>>
           } = private_key
  end

  test "derive the first child of a private key" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    index = 0

    {:ok, child_private_key} = PrivateKey.derive_child(private_key, index)

    assert %PrivateKey{
             key: <<0x39F329FEDBA2A68E2A804FCD9AEEA4104ACE9080212A52CE8B52C1FB89850C72::256>>,
             chain_code:
               <<0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31::256>>,
             depth: 1,
             index: 0,
             parent_fingerprint: <<0x18C1259::32>>
           } = child_private_key
  end

  test "serialize a master private key" do
    serialized =
      %PrivateKey{
        key: <<0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35::256>>,
        chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>,
        depth: 0,
        index: 0,
        parent_fingerprint: <<0::32>>
      }
      |> PrivateKey.serialize()

    assert "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi" ==
             serialized
  end

  test "deserialize a master private key" do
    serialized =
      "xprv9s21ZrQH143K2MPKHPWh91wRxLKehoCNsRrwizj2xNaj9zD5SHMNiHJesDEYgJAavgNE1fDWLgYNneHeSA8oVeVXVYomhP1wxdzZtKsLJbc"

    private_key =
      serialized
      |> PrivateKey.deserialize()

    assert %PrivateKey{
             key: <<0x81549973BAFBBA825B31BCC402A3C4ED8E3185C2F3A31C75E55F423E9629AA3::256>>,
             chain_code:
               <<0x1D7D2A4C940BE028B945302AD79DD2CE2AFE5ED55E1A2937A5AF57F8401E73DD::256>>,
             depth: 0,
             index: 0
           } == private_key
  end

  test "get private key according to the minimal derivation path" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    {:ok, child_private_key} =
      PrivateKey.from_derivation_path(
        private_key,
        "m"
      )

    assert %PrivateKey{
             key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
             chain_code:
               <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>,
             depth: 0,
             index: 0,
             parent_fingerprint: <<0::32>>
           } = child_private_key
  end

  test "get private key straight from a derivation path as a string" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    child_private_key =
      PrivateKey.from_derivation_path!(
        private_key,
        "m"
      )

    assert %PrivateKey{
             key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
             chain_code:
               <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>,
             depth: 0,
             index: 0,
             parent_fingerprint: <<0::32>>
           } = child_private_key
  end

  test "get private master bip44 key" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    {:ok, derivation_path} = DerivationPath.parse("m/44'")

    {:ok, child_private_key} =
      PrivateKey.from_derivation_path(
        private_key,
        derivation_path
      )

    assert %PrivateKey{
             key: <<0x4E59086C1DEC6D081986CB079F536E38B3D2B6DA7A8EDCFFB1942AE8B9FDF156::256>>,
             chain_code:
               <<0xF42DE823EE78F6227822D79BC6F6101D084D7F0F876B7828BF027D681294E538::256>>,
             depth: 1,
             index: 0x8000002C,
             parent_fingerprint: <<0x18C1259::32>>
           } = child_private_key
  end

  test "derive child without using the %DerivationPath struct" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    {:ok, child_private_key} =
      PrivateKey.from_derivation_path(
        private_key,
        "m/44'"
      )

    assert %PrivateKey{
             key: <<0x4E59086C1DEC6D081986CB079F536E38B3D2B6DA7A8EDCFFB1942AE8B9FDF156::256>>,
             chain_code:
               <<0xF42DE823EE78F6227822D79BC6F6101D084D7F0F876B7828BF027D681294E538::256>>,
             depth: 1,
             index: 0x8000002C,
             parent_fingerprint: <<0x18C1259::32>>
           } = child_private_key
  end

  test "get private master bip44, bitcoin mainnet key" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    {:ok, derivation_path} = DerivationPath.parse("m/44'/0'")

    {:ok, child_private_key} =
      PrivateKey.from_derivation_path(
        private_key,
        derivation_path
      )

    assert %PrivateKey{
             key: <<0xD5FF7F3CDA0028C81AB6E4137BB0F391049EB35608FDF84B0305F283A93A1963::256>>,
             chain_code:
               <<0x121AD45C595D75BE41D6578BEB92AD464243C9C60F7CD51DBC70007FC2E1DF14::256>>,
             depth: 2,
             index: 0x80000000,
             parent_fingerprint: <<0x68B1F6F8::32>>
           } = child_private_key
  end

  test "get private master bip44, bitcoin mainnet, account 0 key" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    {:ok, derivation_path} = DerivationPath.parse("m/44'/0'/0'")

    {:ok, child_private_key} =
      PrivateKey.from_derivation_path(
        private_key,
        derivation_path
      )

    assert %PrivateKey{
             key: <<0x762C3ABCFFBB912B86DD72D6ACA0D02127CF93DB04C96130A43BBBE724F938C5::256>>,
             chain_code:
               <<0xF1DCD43D3F65B67ECC7140BBD6FD3422DCB1CBD1FAA610140D89743D1623DE50::256>>,
             depth: 3,
             index: 0x80000000,
             parent_fingerprint: <<0xB9CC499A::32>>
           } = child_private_key
  end

  test "get private master bip44, bitcoin mainnet, account 0, change key" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    {:ok, derivation_path} = DerivationPath.parse("m/44'/0'/0'/1")

    {:ok, child_private_key} =
      PrivateKey.from_derivation_path(
        private_key,
        derivation_path
      )

    assert %PrivateKey{
             key: <<0x41C5644125161F1B3382A175442F545815302D60F1D0F4D52B097B67C6B8C8F9::256>>,
             chain_code:
               <<0xAFC5B0F32E8D0028F19B3D664192A3A7FBC8EC6269F2BEF42897148BC34CA2ED::256>>,
             depth: 4,
             index: 1,
             parent_fingerprint: <<0x8DF69D92::32>>,
             fingerprint: <<0xb4ea7af3::32>>
           } == child_private_key
  end

  test "get private master bip44, bitcoin mainnet, account 0, change, index 0 key" do
    private_key = %PrivateKey{
      key: <<0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9::256>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }

    {:ok, derivation_path} = DerivationPath.parse("m/44'/0'/0'/1/0")

    {:ok, child_private_key} =
      PrivateKey.from_derivation_path(
        private_key,
        derivation_path
      )

    assert %PrivateKey{
             key: <<0x181DCB172F5B56DB39B6C8544068FEE69928556230B41E115BDB22BF82A06FF3::256>>,
             chain_code:
               <<0xAB3ECF35A71958C7E7A0E9A47C4E538CCF1D933554BC36CBE234B94056CDDBF::256>>,
             depth: 5,
             index: 0,
             parent_fingerprint: <<0xB4EA7AF3::32>>
           } = child_private_key
  end

  test "a derived key must have a fingerprint" do
    master_private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> PrivateKey.from_seed_phrase()

    private_key = PrivateKey.from_derivation_path!(master_private_key, "m/49'/0'/0'/0/0")

    assert <<0x17f8b50f::32>> = private_key.fingerprint
  end
end
