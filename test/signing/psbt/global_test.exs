defmodule BitcoinLib.Signing.Psbt.GlobalTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Signing.Psbt.Global

  alias BitcoinLib.Signing.Psbt.{Global}
  alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}

  @psbt_global_unsigned_tx 0
  @stop 0

  test "extract a global module from a binary, with one keypair and no remaining data" do
    key = <<2, @psbt_global_unsigned_tx, 1>>
    value = <<2, 1, 1>>
    keypair = key <> value
    data = <<keypair::binary, @stop>>

    {global, remaining_data} =
      data
      |> Global.from_data()

    keypair1 = global.keypairs |> List.first()

    assert 1 == Enum.count(global.keypairs)
    assert %Key{keylen: 2, keytype: @psbt_global_unsigned_tx, keydata: <<1>>} == keypair1.key
    assert %Value{valuelen: 2, valuedata: <<1, 1>>} == keypair1.value
    assert <<>> == remaining_data
  end
end
