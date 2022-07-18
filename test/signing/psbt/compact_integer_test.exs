defmodule BitcoinLib.Signing.Psbt.CompactIntegerTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Signing.Psbt.CompactInteger

  alias BitcoinLib.Signing.Psbt.CompactInteger

  test "parse a 8 bits compact integer, with no rest" do
    data = <<2>>

    {number, rest} =
      data
      |> CompactInteger.extract_from()
      |> IO.inspect()

    assert 2 == number
    assert <<>> == rest
  end
end
