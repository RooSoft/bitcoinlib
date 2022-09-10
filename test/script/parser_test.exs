defmodule BitcoinLib.Script.ParserTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Script.Parser

  alias BitcoinLib.Script.Parser
  alias BitcoinLib.Script.Opcodes.{BitwiseLogic, Constants, Crypto, Data, Stack}

  test "parse a script only containing zero" do
    script = <<0>>

    opcodes = Parser.parse(script)

    assert [%Constants.Zero{}] = opcodes
  end

  test "parse a P2PKH script" do
    script = <<0x76A914725EBAC06343111227573D0B5287954EF9B88AAE88AC::200>>

    opcodes = Parser.parse(script)

    assert [
             %Stack.Dup{},
             %Crypto.Hash160{},
             %Data{value: <<0x725EBAC06343111227573D0B5287954EF9B88AAE::160>>},
             %BitwiseLogic.EqualVerify{},
             %Crypto.CheckSig{}
           ] = opcodes
  end
end
