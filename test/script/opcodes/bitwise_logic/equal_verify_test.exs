defmodule BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerifyTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify

  alias BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify

  @opcode_value 0x88

  test "OP_EQUAL_VERIFY opcode has the 0x88 value" do
    result = EqualVerify.v()

    assert @opcode_value = result
  end

  test "execute OP_EQUAL_VERIFY on an empty stack" do
    stack = []

    {:error, message} = EqualVerify.execute(%EqualVerify{}, stack)

    assert "trying to execute OP_EQUAL_VERIFY on an empty stack" == message
  end

  test "execute OP_EQUAL_VERIFY on a stack with a single item" do
    stack = [1]

    {:error, message} = EqualVerify.execute(%EqualVerify{}, stack)

    assert message =~ "trying to execute OP_EQUAL_VERIFY on a stack with a single element"
  end

  test "execute OP_EQUAL_VERIFY on a stack" do
    stack = [5, 5, 6]

    {:ok, stack} = EqualVerify.execute(%EqualVerify{}, stack)

    assert [6] == stack
  end
end
