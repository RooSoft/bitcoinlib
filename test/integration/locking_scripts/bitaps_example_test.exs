defmodule BitcoinLib.Test.Integration.LockingScripts.BitapsExampleTest do
  @moduledoc """
  bitaps example from medium.com
  https://medium.com/@bitaps.com/exploring-bitcoin-signing-the-p2pkh-input-b8b4d5c4809c#50a6
  """
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.PrivateKey
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Input, Output}

  @doc """
  We have 1.3 tBTC on mvJe9AfPLrxpfHwjLNjDAiVsFSzwBGaMSP and want transfer it to n4AYuETorj4gYKendz2ndm9QhjUuruZnfk

  Private Key: cThjSL4HkRECuDxUTnfAmkXFBEg78cufVBy3ZfEhKoxZo6Q38R5L
  Address: mvJe9AfPLrxpfHwjLNjDAiVsFSzwBGaMSP
  Input transaction: 5e2383defe7efcbdc9fdd6dba55da148b206617bbb49e6bb93fce7bfbb459d44
  Input transaction output: 1
  Input amount:  1.3000000
  """
  test "bitcoin testnet signing P2PKH " do
    private_key =
      "cThjSL4HkRECuDxUTnfAmkXFBEg78cufVBy3ZfEhKoxZo6Q38R5L"
      |> PrivateKey.from_wif()

    # the transaction can be found in a block explorer such as here:
    # https://mempool.space/testnet/tx/5e2383defe7efcbdc9fdd6dba55da148b206617bbb49e6bb93fce7bfbb459d44

    # we use the second UTXO, which has this script pub key:
    # [
    #   %BitcoinLib.Script.Opcodes.Stack.Dup{},
    #   %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
    #   %BitcoinLib.Script.Opcodes.Data{value: <<0xf86f0bc0a2232970ccdf4569815db500f1268361::160>>},
    #   %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
    #   %BitcoinLib.Script.Opcodes.CheckSig{}
    # ]
    # TODO: create the scriptPubKey by encoding the above script
    script_pub_key = <<0x76A914F86F0BC0A2232970CCDF4569815DB500F126836188AC::200>>

    transaction_hex =
      create_unsigned_transaction_hex(%{
        txid: "5e2383defe7efcbdc9fdd6dba55da148b206617bbb49e6bb93fce7bfbb459d44",
        vout: 1,
        value: 129_000_000,
        script_pub_key: script_pub_key
      })

    # sign this transaction
    # signature = PrivateKey.sign_message(hex_transaction, private_key)

    # and spend it using https://mempool.space/testnet/tx/4484ec8b4801ada92fc4d9a90bb7d9336d02058e9547d027fa0a5fc9d2c9cc77

    assert %Transaction{
             version: 1,
             inputs: [%Input{}],
             outputs: [%Output{}],
             locktime: 0
           } = transaction_hex

    assert %PrivateKey{
             key: <<0xB6A42D01917404B740F9EF9D5CEF08E13F998011246874DD65C033C4669E7009::256>>
           } = private_key
  end

  defp create_unsigned_transaction_hex(%{
         txid: txid,
         vout: vout,
         value: value,
         script_pub_key: script_pub_key
       }) do
    %Transaction{
      version: 1,
      inputs: [%Input{txid: txid, vout: vout, sequence: 0xFFFFFFFF}],
      outputs: [%Output{script_pub_key: script_pub_key, value: value}],
      locktime: 0
    }
  end
end
