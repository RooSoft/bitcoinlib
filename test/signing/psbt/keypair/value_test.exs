defmodule BitcoinLib.Signing.Psbt.Keypair.ValueTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Signing.Psbt.Keypair.Value

  alias BitcoinLib.Signing.Psbt.Keypair.Value

  test "parse a value with no remaining data" do
    data = <<2, 1, 1>>

    {key, data} =
      data
      |> Value.extract_from()

    assert %Value{valuelen: 2, valuedata: <<1, 1>>} == key
    assert <<>> == data
  end

  test "parse a key with some remaining data" do
    data = <<2, 3, 4, 2, 3, 4>>

    {key, data} =
      data
      |> Value.extract_from()

    assert %Value{valuelen: 2, valuedata: <<3, 4>>} == key
    assert <<2, 3, 4>> == data
  end
end
