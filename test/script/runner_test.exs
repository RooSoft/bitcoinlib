defmodule BitcoinLib.Script.RunnerTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Script.Runner

  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Script.Runner
  alias BitcoinLib.Script.Opcodes.{Data, BitwiseLogic, Crypto, Stack}

  test "run a basic script from an opcode list" do
    private_key = %PrivateKey{key: PrivateKey.generate().raw}
    public_key = PublicKey.from_private_key(private_key)
    public_key_hash = PublicKey.hash(public_key)

    opcodes = [
      %Stack.Dup{},
      %Crypto.Hash160{},
      %Data{value: public_key_hash},
      %BitwiseLogic.EqualVerify{}
    ]

    initial_stack = [public_key.key]

    {:ok, result} = Runner.execute(opcodes, initial_stack)

    assert true == result
  end
end
