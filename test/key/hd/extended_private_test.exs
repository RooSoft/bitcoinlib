defmodule BitcoinLib.Key.HD.ExtendedPrivateTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPrivate

  alias BitcoinLib.Key.HD.{ExtendedPrivate, MnemonicSeed}

  test "creates a WIF from a private key" do
    seed =
      0x67F93560761E20617DE26E0CB84F7234AAF373ED2E66295C3D7397E6D7EBE882EA396D5D293808B0DEFD7EDD2BABD4C091AD942E6A9351E6D075A29D4DF872AF

    extended_private_key =
      seed
      |> ExtendedPrivate.from_seed()

    assert %{
             chain_code: _,
             key: _
           } = extended_private_key
  end

  test "extract the master extended private key from a mnemonic" do
    # inspired by https://github.com/zyield/block_keys/blob/f5c28c885872e24e99d07fd6f1c1c967cd63ae3f/test/block_keys/ckd_test.exs#L84

    mnemonic =
      "safe result wire cattle sauce luggage couple legend pause rather employ pear " <>
        "trigger live daring unlock music lyrics smoke mistake endorse kite obey siren"

    seed = MnemonicSeed.to_seed(mnemonic)

    %{key: private_key, chain_code: chain_code} =
      seed
      |> ExtendedPrivate.from_seed()

    assert private_key == 0x30A6B59CCCC924FC9FFD4AB08C5C01F0D6A4046797BB255D8919EB3E95C08871
    assert chain_code == 0xE08FCC54429E47AC55FEBD4DC9EDCCC88D292EB40AA3765AF3DA7178A14AA114
  end

  test "derive the first child of a private key" do
    private_key = 0xF79BB0D317B310B261A55A8AB393B4C8A1ABA6FA4D08AEF379CABA502D5D67F9
    chain_code = 0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B
    index = 0

    {:ok, child_private_key, child_chain_code} =
      BitcoinLib.Key.HD.ExtendedPrivate.derive_child(private_key, chain_code, index)

    assert child_private_key == 0x39F329FEDBA2A68E2A804FCD9AEEA4104ACE9080212A52CE8B52C1FB89850C72
    assert child_chain_code == 0x05AAE71D7C080474EFAAB01FA79E96F4C6CFE243237780B0DF4BC36106228E31
  end
end
