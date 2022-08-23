defmodule BitcoinLib.TransactionTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Transaction

  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Input, Output}

  test "decode a transaction" do
    raw =
      "01000000017b1eabe0209b1fe794124575ef807057c77ada2138ae4fa8d6c4de0398a14f3f0000000000ffffffff01f0ca052a010000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac00000000"
      |> Binary.from_hex()

    {:ok, transaction} = Transaction.decode(raw)

    assert 1 == transaction.version
    assert 0 == transaction.locktime

    assert 1 == Enum.count(transaction.inputs)
    assert 1 == Enum.count(transaction.outputs)

    assert %Input{
             script_sig: <<>>,
             sequence: 0xFFFFFFFF,
             txid: "3f4fa19803dec4d6a84fae3821da7ac7577080ef75451294e71f9b20e0ab1e7b",
             vout: 0x0
           } = List.first(transaction.inputs)

    assert %Output{
             script_pub_key: [
               %BitcoinLib.Script.Opcodes.Stack.Dup{},
               %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
               %BitcoinLib.Script.Opcodes.Data{
                 value: <<0xCBC20A7664F2F69E5355AA427045BC15E7C6C772::160>>
               },
               %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
               %BitcoinLib.Script.Opcodes.Crypto.CheckSig{
                 script:
                   <<118, 169, 20, 203, 194, 10, 118, 100, 242, 246, 158, 83, 85, 170, 66, 112,
                     69, 188, 21, 231, 198, 199, 114, 136, 172>>
               }
             ],
             value: 0x12A05CAF0
           } = List.first(transaction.outputs)
  end
end
