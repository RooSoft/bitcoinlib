defmodule BitcoinLib.Crypto.ConvertTest do
  use ExUnit.Case

  alias BitcoinLib.Crypto.Convert

  test "converts an integer into a bitstring" do
    value = 0x0A8D286B11B98F6CB2585B627FF44D12059560ACD430DCFA1260EF2BD9569373

    binary = Convert.integer_to_binary(value)

    assert binary ==
             <<10, 141, 40, 107, 17, 185, 143, 108, 178, 88, 91, 98, 127, 244, 77, 18, 5, 149, 96,
               172, 212, 48, 220, 250, 18, 96, 239, 43, 217, 86, 147, 115>>
  end

  test "converts the minimal integer into a bitstring" do
    value = 1

    binary = Convert.integer_to_binary(value)

    assert binary ==
             <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 1>>
  end
end
