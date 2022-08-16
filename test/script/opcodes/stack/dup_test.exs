defmodule BitcoinLib.Script.Opcodes.Stack.DupTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Script.Opcodes.Stack.Dup

  alias BitcoinLib.Script.Opcodes.Stack.Dup

  @opcode_value 0x76

  test "OP_DUP opcode has the 0x76 value" do
    result = Dup.v()

    assert @opcode_value = result
  end

  test "execute OP_DUP on a stack" do
    stack = [1, 2, 3, 4]

    {:ok, result} = Dup.execute(%Dup{}, stack)

    assert [1, 1, 2, 3, 4] == result
  end

  test "execute OP_DUP on an empty stack" do
    stack = []

    {:error, message} = Dup.execute(%Dup{}, stack)

    assert "trying to execute OP_DUP on an empty stack" == message
  end
end
