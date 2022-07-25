defmodule BitcoinLib.TransactionTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Transaction

  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Input, Output}

  test "decode a transaction" do
    raw =
      "01000000017b1eabe0209b1fe794124575ef807057c77ada2138ae4fa8d6c4de0398a14f3f0000000000ffffffff01f0ca052a010000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac00000000"
      |> Binary.from_hex()

    transaction = Transaction.decode(raw)

    assert 1 == Enum.count(transaction.inputs)
    assert 1 == Enum.count(transaction.outputs)

    assert %Input{
             script_sig: 0x0,
             sequence: 0xFFFFFFFF,
             txid: 0x3F4FA19803DEC4D6A84FAE3821DA7AC7577080EF75451294E71F9B20E0AB1E7B,
             vout: 0x0
           } = List.first(transaction.inputs)

    assert %Output{
             script_pub_key: 0xED5229,
             value: 0x12A05CAF0
           } = List.first(transaction.outputs)
  end
end
