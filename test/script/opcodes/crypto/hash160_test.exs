defmodule BitcoinLib.Script.Opcodes.Crypto.Hash160Test do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Script.Opcodes.Crypto.Hash160

  alias BitcoinLib.Script.Opcodes.Crypto.Hash160

  @opcode_value 0xA9

  test "OP_HASH160 opcode has the 0xA9 value" do
    result = Hash160.v()

    assert @opcode_value = result
  end

  test "execute OP_HASH160 on a stack" do
    stack = ["6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"]

    {:ok, result} = Hash160.execute(stack)

    assert ["273f29c643d908664fcc61aa2ec76e4f21196fcb"] == result
  end

  test "execute OP_HASH160 on an empty stack" do
    stack = []

    {:error, message} = Hash160.execute(stack)

    assert "trying to execute OP_HASH160 on an empty stack" == message
  end
end
