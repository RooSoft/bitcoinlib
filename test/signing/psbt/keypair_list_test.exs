defmodule BitcoinLib.Signing.Psbt.KeypairListTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Signing.Psbt.KeypairList

  alias BitcoinLib.Signing.Psbt.{KeypairList, Keypair}
  alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}

  @psbt_global_unsigned_tx 0
  @stop 0

  test "extract a keypair list from a binary, with one keypair and no remaining data" do
    key = <<2, @psbt_global_unsigned_tx, 1>>
    value = <<2, 1, 1>>
    keypair = key <> value
    data = <<keypair::binary, @stop>>

    {keypair_list, remaining_data} =
      data
      |> KeypairList.from_data()

    %Keypair{} = keypair1 = keypair_list.keypairs |> List.first()

    assert 1 == Enum.count(keypair_list.keypairs)
    assert %Key{keylen: 2, keytype: @psbt_global_unsigned_tx, keydata: <<1>>} == keypair1.key
    assert %Value{length: 2, data: <<1, 1>>} == keypair1.value
    assert <<>> == remaining_data
  end

  test "extract a keypair list from a binary, with two keypairs and no remaining data" do
    key = <<2, @psbt_global_unsigned_tx, 1>>
    value = <<2, 1, 1>>
    keypair = key <> value
    data = <<keypair::binary, keypair::binary, @stop>>

    {keypair_list, remaining_data} =
      data
      |> KeypairList.from_data()

    assert 2 == Enum.count(keypair_list.keypairs)
    assert <<>> == remaining_data
  end

  test "extract a keypair list from a binary, with two keypairs and some remaining data" do
    key = <<2, @psbt_global_unsigned_tx, 1>>
    value = <<2, 1, 1>>
    keypair = key <> value
    remaining_data = <<5, 1>>
    data = <<keypair::binary, @stop, remaining_data::binary>>

    {keypair_list, remaining_data} =
      data
      |> KeypairList.from_data()

    assert 1 == Enum.count(keypair_list.keypairs)
    assert <<5, 1>> == remaining_data
  end
end
