defmodule BitcoinLib.Script.RunnerTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Script.Runner
  alias BitcoinLib.Script.Opcodes.{Data, BitwiseLogic, Crypto, Stack}

  test "run a P2PKH script from an opcode list" do
    pub_key = <<0x03EB181FB7B5CF63D82307188B20828B83008F2D2511E5C6EDCBE171C63DD2CBC1::264>>

    sig =
      <<0x3045022100A9A1CEB7B278D7EC33BEAEC3A8D53A466C5553E0A218DECD7357703E9C25172E022053555BB91729EB9F1488DFB286A949D481A4D7D8735CB92BBBE92A24D4532D30::568>>

    opcodes = [
      %Stack.Dup{},
      %Crypto.Hash160{},
      %Data{value: <<0x725EBAC06343111227573D0B5287954EF9B88AAE::160>>},
      %BitwiseLogic.EqualVerify{},
      %Crypto.CheckSig{script: <<0x76A914725EBAC06343111227573D0B5287954EF9B88AAE88AC::200>>}
    ]

    initial_stack = [pub_key, sig]

    {:ok, result} = Runner.execute(opcodes, initial_stack)

    assert true == result
  end
end
