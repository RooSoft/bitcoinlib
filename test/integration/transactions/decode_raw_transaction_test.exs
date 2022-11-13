defmodule BitcoinLib.Test.Integration.Transactions.DecodeRawTransactionTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Transaction

  test "decode a raw transaction" do
    # Based on https://mempool.space/tx/57160d4195892d58242f197d263cf55580ad57efd673c3965c660654ebc7fbe0

    raw =
      <<0x2000000016D1C6ECBCF6C380D60F1FEDD82AE09CE3607E7ABF59B9B6C3E712576F6D7FB03010000006A47304402206D283E6B073BCC2E2C55D08E1E45A1B5D23AA6D5910901E0A6B7ED20BC06B60F0220264884FFCA83B0155FBFEE63470DC7F067820C8AD4AA4BA004BD086CBA096D6B0121037AF82DEA659A2A4892EB72F46C6964083F082ED7E367E0A42AD8B655EB97C251FFFFFFFF021F810100000000001976A9148C7A6DA80409C9A1F93ED9F3A8A48E8A0951947F88AC63F21500000000001976A914DA0575E01F4C7E856184A12847AB075F8DAAEFEE88AC00000000::1800>>

    {:ok, transaction} = Transaction.decode(raw)

    assert transaction == %BitcoinLib.Transaction{
             version: 2,
             id: "57160d4195892d58242f197d263cf55580ad57efd673c3965c660654ebc7fbe0",
             inputs: [
               %BitcoinLib.Transaction.Input{
                 txid: "03fbd7f67625713e6c9b9bf5abe70736ce09ae82ddfef1600d386ccfcb6e1c6d",
                 vout: 1,
                 script_sig: [
                   %BitcoinLib.Script.Opcodes.Data{
                     value:
                       <<0x304402206D283E6B073BCC2E2C55D08E1E45A1B5D23AA6D5910901E0A6B7ED20BC06B60F0220264884FFCA83B0155FBFEE63470DC7F067820C8AD4AA4BA004BD086CBA096D6B01::568>>
                   },
                   %BitcoinLib.Script.Opcodes.Data{
                     value:
                       <<0x037AF82DEA659A2A4892EB72F46C6964083F082ED7E367E0A42AD8B655EB97C251::264>>
                   }
                 ],
                 sequence: 4_294_967_295
               }
             ],
             outputs: [
               %BitcoinLib.Transaction.Output{
                 value: 98591,
                 script_pub_key: [
                   %BitcoinLib.Script.Opcodes.Stack.Dup{},
                   %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
                   %BitcoinLib.Script.Opcodes.Data{
                     value: <<0x8C7A6DA80409C9A1F93ED9F3A8A48E8A0951947F::160>>
                   },
                   %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
                   %BitcoinLib.Script.Opcodes.Crypto.CheckSig{
                     script: <<0x76A9148C7A6DA80409C9A1F93ED9F3A8A48E8A0951947F88AC::200>>
                   }
                 ]
               },
               %BitcoinLib.Transaction.Output{
                 value: 1_438_307,
                 script_pub_key: [
                   %BitcoinLib.Script.Opcodes.Stack.Dup{},
                   %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
                   %BitcoinLib.Script.Opcodes.Data{
                     value: <<0xDA0575E01F4C7E856184A12847AB075F8DAAEFEE::160>>
                   },
                   %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
                   %BitcoinLib.Script.Opcodes.Crypto.CheckSig{
                     script: <<0x76A914DA0575E01F4C7E856184A12847AB075F8DAAEFEE88AC::200>>
                   }
                 ]
               }
             ],
             locktime: 0,
             segwit?: false,
             witness: []
           }
  end
end
