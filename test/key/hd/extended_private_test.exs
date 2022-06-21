defmodule BitcoinLib.Key.HD.ExtendedPrivateTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPrivate

  alias BitcoinLib.Key.HD.{DerivationPath, ExtendedPrivate, MnemonicSeed}

  test "returns an extended private key from a seed" do
    seed =
      "67f93560761e20617de26e0cb84f7234aaf373ed2e66295c3d7397e6d7ebe882ea396d5d293808b0defd7edd2babd4c091ad942e6a9351e6d075a29d4df872af"

    extended_private_key =
      seed
      |> ExtendedPrivate.from_seed()

    assert %ExtendedPrivate{
             key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
             chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
           } = extended_private_key
  end

  test "extract the master extended private key from a mnemonic" do
    # inspired by https://github.com/zyield/block_keys/blob/f5c28c885872e24e99d07fd6f1c1c967cd63ae3f/test/block_keys/ckd_test.exs#L84

    mnemonic =
      "safe result wire cattle sauce luggage couple legend pause rather employ pear " <>
        "trigger live daring unlock music lyrics smoke mistake endorse kite obey siren"

    seed = MnemonicSeed.to_seed(mnemonic)

    private_key =
      seed
      |> ExtendedPrivate.from_seed()

    %ExtendedPrivate{
      key: 0x30A6B59CCCC924FC9FFD4AB08C5C01F0D6A4046797BB255D8919EB3E95C08871,
      chain_code: 0xE08FCC54429E47AC55FEBD4DC9EDCCC88D292EB40AA3765AF3DA7178A14AA114,
      depth: 0,
      index: 0,
      parent_fingerprint: 0
    } = private_key
  end

  test "derive the first child of a private key" do
    private_key = %ExtendedPrivate{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    index = 0

    {:ok, child_private_key} = ExtendedPrivate.derive_child(private_key, index)

    %ExtendedPrivate{
      key: 0x39F329FEDBA2A68E2A804FCD9AEEA4104ACE9080212A52CE8B52C1FB89850C72,
      chain_code: 0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31,
      depth: 1,
      index: 0,
      parent_fingerprint: 0x18C12595
    } = child_private_key
  end

  test "serialize a master private key" do
    serialized =
      %ExtendedPrivate{
        key: 0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35,
        chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508,
        depth: 0,
        index: 0,
        parent_fingerprint: 0
      }
      |> BitcoinLib.Key.HD.ExtendedPrivate.serialize()

    assert "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi" ==
             serialized
  end

  test "deserialize a master private key" do
    serialized =
      "xprv9s21ZrQH143K2MPKHPWh91wRxLKehoCNsRrwizj2xNaj9zD5SHMNiHJesDEYgJAavgNE1fDWLgYNneHeSA8oVeVXVYomhP1wxdzZtKsLJbc"

    private_key =
      serialized
      |> BitcoinLib.Key.HD.ExtendedPrivate.deserialize()

    assert %ExtendedPrivate{
             key: 0x81549973BAFBBA825B31BCC402A3C4ED8E3185C2F3A31C75E55F423E9629AA3,
             chain_code: 0x1D7D2A4C940BE028B945302AD79DD2CE2AFE5ED55E1A2937A5AF57F8401E73DD,
             depth: 0,
             index: 0,
             parent_fingerprint: 0
           } == private_key
  end

  test "get private key according to the minimal derivation path" do
    private_key = %ExtendedPrivate{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    {:ok, child_private_key} =
      ExtendedPrivate.from_derivation_path(
        private_key,
        "m"
      )

    assert %ExtendedPrivate{
             key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
             chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B,
             depth: 0,
             index: 0,
             parent_fingerprint: 0
           } = child_private_key
  end

  test "get private master bip44 key" do
    private_key = %ExtendedPrivate{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    {:ok, derivation_path} = DerivationPath.parse("m/44'")

    {:ok, child_private_key} =
      ExtendedPrivate.from_derivation_path(
        private_key,
        derivation_path
      )

    assert %ExtendedPrivate{
             key: 0xDBC0D83640688A51F40B0FB28AC87687B745E2E774AA3AD68F7F11894CC98DB1,
             chain_code: 0x7910F96A0809BD47AF3B86DB0933A3BD8E1433E807F37059FA7B93939C5EF2,
             parent_fingerprint: 0x18C12595
           } = child_private_key
  end

  test "derive child without using the %DerivationPath struct" do
    private_key = %ExtendedPrivate{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    {:ok, child_private_key} =
      ExtendedPrivate.from_derivation_path(
        private_key,
        "m/44'"
      )

    assert %ExtendedPrivate{
             key: 0xDBC0D83640688A51F40B0FB28AC87687B745E2E774AA3AD68F7F11894CC98DB1,
             chain_code: 0x7910F96A0809BD47AF3B86DB0933A3BD8E1433E807F37059FA7B93939C5EF2,
             depth: 1,
             index: 0x8000002C,
             parent_fingerprint: 0x18C12595
           } = child_private_key
  end

  test "get private master bip44, bitcoin mainnet key" do
    private_key = %ExtendedPrivate{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    {:ok, derivation_path} = DerivationPath.parse("m/44'/0'")

    {:ok, child_private_key} =
      ExtendedPrivate.from_derivation_path(
        private_key,
        derivation_path
      )

    assert %ExtendedPrivate{
             key: 0xCBA660EBA950D36AE1BAE071DA2BA96C6573D7C15DAE2D36099F408211ED7D31,
             chain_code: 0x36E1EB21FC299D5CE2A4CF4468B743A17666CC4DC47207CF9C8EB4E1BD,
             parent_fingerprint: 0x5D3E28E0
           } = child_private_key
  end

  test "get private master bip44, bitcoin mainnet, account 0 key" do
    private_key = %ExtendedPrivate{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    {:ok, derivation_path} = DerivationPath.parse("m/44'/0'/0'")

    {:ok, child_private_key} =
      ExtendedPrivate.from_derivation_path(
        private_key,
        derivation_path
      )

    assert child_private_key.key ==
             0x5BA6080E4016B8C557A1BDD0563427E785FC6AC325ED209EE1BD121827180C12

    assert child_private_key.chain_code ==
             0xAB49104797CBBDA6D4CA5A6F3EC701D2F1D09D776C7991AC79517E6CAEFB75
  end

  test "get private master bip44, bitcoin mainnet, account 0, change key" do
    private_key = %ExtendedPrivate{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    {:ok, derivation_path} = DerivationPath.parse("m/44'/0'/0'/1")

    {:ok, child_private_key} =
      ExtendedPrivate.from_derivation_path(
        private_key,
        derivation_path
      )

    assert child_private_key.key ==
             0x85BA547116863652CBB8D943D6AAEC156A7B6C6B156DF5793A4A7DAA3A0B90E9

    assert child_private_key.chain_code ==
             0x24D97713BA47F418F17252FD145B6C276254228865149A6F45D7E5B62F4BA4AC
  end

  test "get private master bip44, bitcoin mainnet, account 0, change, index 0 key" do
    private_key = %ExtendedPrivate{
      key: 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9,
      chain_code: 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    }

    {:ok, derivation_path} = DerivationPath.parse("m/44'/0'/0'/1/0")

    {:ok, child_private_key} =
      ExtendedPrivate.from_derivation_path(
        private_key,
        derivation_path
      )

    assert child_private_key.key ==
             0x2FD9D422D63D2D351DFA495AC42D481B278B7702500D37C2EEB2E5FA5A063B26

    assert child_private_key.chain_code ==
             0xC6A61F89923A032098326DBBFE4036EA648C0D01FD595288D619C6822626941C
  end
end
