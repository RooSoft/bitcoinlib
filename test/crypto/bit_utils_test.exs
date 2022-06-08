defmodule BitcoinLib.Key.BitUtilsTest do
  use ExUnit.Case

  doctest BitcoinLib.Crypto.BitUtils

  alias BitcoinLib.Crypto.BitUtils

  test "split a binary in chunks of a specified size in bits" do
    value =
      0x6C7AB2F961A
      |> Binary.from_integer()

    tokens = BitUtils.split(value, 11)

    assert tokens == [
             <<6, 6::size(3)>>,
             <<61, 2::size(3)>>,
             <<203, 7::size(3)>>,
             <<44, 1::size(3)>>,
             <<10::size(4)>>
           ]
  end

  test "combine a binary list into a single one" do
    tokens = [
      <<6, 6::size(3)>>,
      <<61, 2::size(3)>>,
      <<203, 7::size(3)>>,
      <<44, 1::size(3)>>,
      <<10::size(4)>>
    ]

    combined = BitUtils.combine(tokens)

    assert combined == <<6, 199, 171, 47, 150, 26>>
  end
end
