defmodule BitcoinLib.Test.Integration.LockingScripts.ManualExampleTest do
  @moduledoc """
  bitaps example from medium.com
  https://medium.com/@bitaps.com/exploring-bitcoin-signing-the-p2pkh-input-b8b4d5c4809c#50a6
  """
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.{PrivateKey, PublicKey, PublicKeyHash}
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Input, Output}
  alias BitcoinLib.Script
  alias BitcoinLib.Script.Opcodes
  alias BitcoinLib.Crypto

  test "bitcoin testnet signing own P2PKH" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> PrivateKey.from_mnemonic_phrase()
      |> PrivateKey.from_derivation_path("m/44'/1'/0'/0/0")
      |> elem(1)

    public_key =
      private_key
      |> PublicKey.from_private_key()

    public_key_hash =
      public_key
      |> PublicKeyHash.from_public_key()

    # the transaction can be found in a block explorer such as here:
    # https://mempool.space/testnet/tx/e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6
    # we use the first UTXO's script pub key from the output in the above transaction:
    redeem_script =
      <<0x76A914AFC3E518577316386188AF748A816CD14CE333F288AC::200>>
      |> Script.parse()

    # found straight in the output of step1 in here:
    # https://medium.com/@bitaps.com/exploring-bitcoin-signing-the-p2pkh-input-b8b4d5c4809c#50a6
    locking_script = [
      %Opcodes.Stack.Dup{},
      %Opcodes.Crypto.Hash160{},
      %Opcodes.Data{value: public_key_hash},
      %Opcodes.BitwiseLogic.EqualVerify{},
      %Opcodes.Crypto.CheckSig{}
    ]

    transaction = %Transaction{
      version: 1,
      inputs: [
        %Input{
          txid: "e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6",
          vout: 0,
          sequence: 0xFFFFFFFF,
          script_sig: redeem_script
        }
      ],
      outputs: [%Output{script_pub_key: locking_script, value: 10_000}],
      locktime: 0
    }

    transaction_hex = Transaction.encode(transaction)

    hashed_preimage =
      transaction_hex
      |> append_sighash(1)
      |> Crypto.double_sha256()

    # DER Encoding reference https://github.com/bitcoin/bips/blob/master/bip-0066.mediawiki#der-encoding-reference
    # must implement DER verification in PrivateKey.sign_message/2 to make sure signatures are valid
    # might also be useful https://github.com/bitcoin/bips/blob/master/bip-0137.mediawiki
    # etotheipi's diagram: https://en.bitcoin.it/wiki/File:Bitcoin_OpCheckSig_InDetail.png
    # OP_CHECKSIG: https://en.bitcoin.it/wiki/OP_CHECKSIG
    # >>>>>>> check this out https://bitcoin.stackexchange.com/questions/3374/how-to-redeem-a-basic-tx <<<<<<<<<<<<
    signature =
      hashed_preimage
      |> PrivateKey.sign_message(private_key)

    is_valid =
      signature
      |> PublicKey.validate_signature(hashed_preimage, public_key)

    assert is_valid

    encoded_signature = Opcodes.Data.encode(%Opcodes.Data{value: <<signature::bitstring, 1>>})
    encoded_public_key = Opcodes.Data.encode(%Opcodes.Data{value: public_key.key})

    script_sig = <<encoded_signature::bitstring, encoded_public_key::bitstring>>

    [old_input] = transaction.inputs
    new_input = %{old_input | script_sig: script_sig}

    transaction = %{transaction | inputs: [new_input]}

    encoded_transaction =
      Transaction.encode(transaction)
      |> Binary.to_hex()

    assert "0100000001b62ba991789fb1739e6a17b3891fd94cfebf09a61fedb203d619932a4326c2e4000000006a4730440220032a1544f599bf29981851e826e8a6f7c036958ba3543cf9778a0756dfc425f6022067eec131c0d73825633c0fddce1abfb14bb26bc9e0d6e9d644a77361f74cb55c012103f0e5a53db9f85e5b2eecf677925ffe21dd1409bcfe9a0730404053599b0901e5ffffffff0110270000000000001976a914afc3e518577316386188af748a816cd14ce333f288ac00000000" =
             encoded_transaction
  end

  defp append_sighash(transaction, sighash) do
    <<transaction::bitstring, sighash::little-32>>
  end
end
