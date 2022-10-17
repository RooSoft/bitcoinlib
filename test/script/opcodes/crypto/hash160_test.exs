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
    stack = [<<0x6C7AB2F961A1BC3F13CDC08DC41C3F439ADEBD549A8EF1C089E81A5907376107::256>>]

    {:ok, result} = Hash160.execute(%Hash160{}, stack)

    assert [<<0x273F29C643D908664FCC61AA2EC76E4F21196FCB::160>>] == result
  end

  test "execute OP_HASH160 on an empty stack" do
    stack = []

    {:error, message} = Hash160.execute(%Hash160{}, stack)

    assert "trying to execute OP_HASH160 on an empty stack" == message
  end
end
