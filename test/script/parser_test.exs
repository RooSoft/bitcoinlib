defmodule BitcoinLib.Script.ParserTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Script.Parser
  # BitwiseLogic, Constants, Crypto, FlowControl, Stack
  alias BitcoinLib.Script.Opcodes.{Constants}

  test "parse a script only containing zero" do
    script = <<0>>

    opcodes = Parser.parse(script)

    assert [%Constants.Zero{}] = opcodes
  end
end
