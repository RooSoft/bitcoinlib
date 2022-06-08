defmodule BitcoinLib.Key.BitUtilsTest do
  use ExUnit.Case

  doctest BitcoinLib.Crypto.BitUtils

  alias BitcoinLib.Crypto.BitUtils

  test "split a binary in chunks of a specified size in bits" do
    value =
      0x6C7AB2F961A
      |> Binary.from_integer()

    integers = BitUtils.split(value, 11)

    assert integers == [
             <<6, 6::size(3)>>,
             <<61, 2::size(3)>>,
             <<203, 7::size(3)>>,
             <<44, 1::size(3)>>,
             <<10::size(4)>>
           ]
  end
end
