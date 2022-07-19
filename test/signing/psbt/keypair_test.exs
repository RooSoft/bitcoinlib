defmodule BitcoinLib.Signing.Psbt.KeypairTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Signing.Psbt.Keypair

  alias BitcoinLib.Signing.Psbt.Keypair
  alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}

  @psbt_global_unsigned_tx 0x00

  test "parse a keypair, with no rest" do
    key = <<2, @psbt_global_unsigned_tx, 1>>
    value = <<2, 1, 1>>
    data = key <> value

    {keypair, data} =
      data
      |> Keypair.extract_from()

    assert %Key{keylen: 2, keytype: @psbt_global_unsigned_tx, keydata: <<1>>} == keypair.key
    assert %Value{length: 2, data: <<1, 1>>} == keypair.value
    assert <<>> == data
  end

  test "parse a keypair, with remaining data" do
    key = <<3, @psbt_global_unsigned_tx, 9, 8>>
    value = <<3, 5, 4, 6>>
    remaining = <<4, 5, 6, 3>>
    data = key <> value <> remaining

    {keypair, remaining} =
      data
      |> Keypair.extract_from()

    assert %Key{keylen: 3, keytype: @psbt_global_unsigned_tx, keydata: <<9, 8>>} == keypair.key
    assert %Value{length: 3, data: <<5, 4, 6>>} == keypair.value
    assert <<4, 5, 6, 3>> == remaining
  end
end
