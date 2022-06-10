defmodule BitcoinLib.Key.HD.ExtendedPrivateTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.HD.ExtendedPrivate

  alias BitcoinLib.Key.HD.{ExtendedPrivate, MnemonicSeed}

  test "creates a WIF from a private key" do
    seed =
      "67f93560761e20617de26e0cb84f7234aaf373ed2e66295c3d7397e6d7ebe882ea396d5d293808b0defd7edd2babd4c091ad942e6a9351e6d075a29d4df872af"

    extended_private_key =
      seed
      |> ExtendedPrivate.from_seed()

    assert %{
             chain_code: _,
             private_key: _
           } = extended_private_key
  end

  test "extract the master extended private key from a mnemonic" do
    # inspired by https://github.com/zyield/block_keys/blob/f5c28c885872e24e99d07fd6f1c1c967cd63ae3f/test/block_keys/ckd_test.exs#L84

    mnemonic =
      "safe result wire cattle sauce luggage couple legend pause rather employ pear " <>
        "trigger live daring unlock music lyrics smoke mistake endorse kite obey siren"

    seed = MnemonicSeed.to_seed(mnemonic)

    %{private_key: private_key, chain_code: chain_code} =
      seed
      |> ExtendedPrivate.from_seed()

    assert private_key ==
             <<48, 166, 181, 156, 204, 201, 36, 252, 159, 253, 74, 176, 140, 92, 1, 240, 214, 164,
               4, 103, 151, 187, 37, 93, 137, 25, 235, 62, 149, 192, 136, 113>>

    assert chain_code ==
             <<224, 143, 204, 84, 66, 158, 71, 172, 85, 254, 189, 77, 201, 237, 204, 200, 141, 41,
               46, 180, 10, 163, 118, 90, 243, 218, 113, 120, 161, 74, 161, 20>>
  end
end
