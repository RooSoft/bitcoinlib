defmodule BitcoinLib.Signing.Psbt.Keypair.KeyTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Signing.Psbt.Keypair.Key

  alias BitcoinLib.Signing.Psbt.Keypair.Key

  @psbt_global_unsigned_tx 0x00

  test "parse a key with no remaining data" do
    data = <<2, @psbt_global_unsigned_tx, 1>>

    {key, data} =
      data
      |> Key.extract_from()

    assert %Key{length: 2, type: @psbt_global_unsigned_tx, data: <<1>>} == key
    assert <<>> == data
  end

  test "parse a key with some remaining data" do
    data = <<2, @psbt_global_unsigned_tx, 1, 2, 3, 4>>

    {key, data} =
      data
      |> Key.extract_from()

    assert %Key{length: 2, type: @psbt_global_unsigned_tx, data: <<1>>} == key
    assert <<2, 3, 4>> == data
  end
end
