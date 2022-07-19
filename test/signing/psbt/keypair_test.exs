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

    { keypair, data } =
      data
      |> Keypair.extract_from()

    assert %Key{keylen: 2, keytype: @psbt_global_unsigned_tx, keydata: <<1>>} == keypair.key
    assert %Value{valuelen: 2, valuedata: <<1, 1>>} == keypair.value
    assert <<>> == data
  end
end
