defmodule BitcoinLib.Signing.Psbt.CompactIntegerTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Signing.Psbt.CompactInteger

  alias BitcoinLib.Signing.Psbt.CompactInteger

  test "parse a 8 bits compact integer, with no rest" do
    data = <<1, 0>>

    {number, rest} =
      data
      |> CompactInteger.extract_from()
      |> IO.inspect()

    assert 0 == number
    assert <<>> == rest
  end
end
