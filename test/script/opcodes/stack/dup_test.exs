defmodule BitcoinLib.Script.Opcodes.Stack.DupTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Script.Opcodes.Stack.Dup

  alias BitcoinLib.Script.Opcodes.Stack.Dup

  @opcode_value 0x76

  test "OP_DUP opcode has the 0x76 value" do
    result = Dup.v()

    assert @opcode_value = result
  end
end
