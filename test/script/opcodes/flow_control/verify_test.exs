defmodule BitcoinLib.Script.Opcodes.FlowControl.VerifyTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Script.Opcodes.FlowControl.Verify

  alias BitcoinLib.Script.Opcodes.FlowControl.Verify

  @opcode_value 0x69

  test "OP_VERIFY opcode has the 0x69 value" do
    result = Verify.v()

    assert @opcode_value = result
  end

  test "execute OP_VERIFY on an empty stack" do
    stack = []

    {:error, message} = Verify.execute(%Verify{}, stack)

    assert "trying to execute OP_VERIFY on an empty stack" == message
  end

  test "execute OP_VERIFY on a stack containing a truthy value on top" do
    stack = [4, 5, 6]

    {:ok, result} = Verify.execute(%Verify{}, stack)

    assert [5, 6] == result
  end

  test "execute OP_VERIFY on a stack containing a falsy value on top" do
    stack = [0, 4, 5]

    {:error, message} = Verify.execute(%Verify{}, stack)

    assert message =~ "the script is invalid, it doesn't pass the OP_VERIFY test"
  end
end
