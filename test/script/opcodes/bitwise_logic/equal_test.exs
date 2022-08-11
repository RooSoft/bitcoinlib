defmodule BitcoinLib.Script.Opcodes.BitwiseLogic.EqualTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Script.Opcodes.BitwiseLogic.Equal

  alias BitcoinLib.Script.Opcodes.BitwiseLogic.Equal

  @opcode_value 0x87

  test "OP_EQUAL opcode has the 0x87 value" do
    result = Equal.v()

    assert @opcode_value = result
  end

  test "execute OP_EQUAL on a stack" do
    stack = [4, 4]

    {:ok, result} = Equal.execute(stack)

    assert [1] == result
  end

  test "execute OP_EQUAL on an empty stack" do
    stack = []

    {:error, message} = Equal.execute(stack)

    assert "trying to execute OP_EQUAL on an empty stack" == message
  end

  test "execute OP_EQUAL on a stack with a single item" do
    stack = [1]

    {:error, message} = Equal.execute(stack)

    assert message =~ "trying to execute OP_EQUAL on a stack with a single element"
  end
end
