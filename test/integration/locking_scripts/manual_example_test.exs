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

  test "same bitcoin testnet signing own P2PKH, but using Transaction.sign_and_encode" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> PrivateKey.from_mnemonic_phrase()
      |> PrivateKey.from_derivation_path("m/44'/1'/0'/0/0")
      |> elem(1)

    public_key_hash =
      private_key
      |> PublicKey.from_private_key()
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

    signed_transaction =
      %Transaction{
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
      |> Transaction.sign_and_encode(private_key)

    assert "0100000001b62ba991789fb1739e6a17b3891fd94cfebf09a61fedb203d619932a4326c2e4000000006a4730440220032a1544f599bf29981851e826e8a6f7c036958ba3543cf9778a0756dfc425f6022067eec131c0d73825633c0fddce1abfb14bb26bc9e0d6e9d644a77361f74cb55c012103f0e5a53db9f85e5b2eecf677925ffe21dd1409bcfe9a0730404053599b0901e5ffffffff0110270000000000001976a914afc3e518577316386188af748a816cd14ce333f288ac00000000" ==
             signed_transaction
  end

  test "create a signed transaction with a change address" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> PrivateKey.from_mnemonic_phrase()
      |> PrivateKey.from_derivation_path("m/44'/1'/0'/0/0")
      |> elem(1)

    {:ok, target_public_key_hash, :p2pkh} =
      "n4YK3tKZPhNA7ENidWPjm6ojCZBivchFR6"
      |> PublicKeyHash.from_address()

    # the transaction can be found in a block explorer such as here:
    # https://mempool.space/testnet/tx/e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6
    # we use the first UTXO's script pub key from the output in the above transaction:
    redeem_script =
      <<0x76A914AFC3E518577316386188AF748A816CD14CE333F288AC::200>>
      |> Script.parse()

    # found straight in the output of step1 in here:
    # https://medium.com/@bitaps.com/exploring-bitcoin-signing-the-p2pkh-input-b8b4d5c4809c#50a6
    locking_script = BitcoinLib.Script.Types.P2pkh.create(target_public_key_hash)

    signed_transaction =
      %Transaction{
        version: 1,
        inputs: [
          %Input{
            txid: "838935b6bf2a16966fe261f23f28a88482f3b3d24c9847b68a56abe90d41ca97",
            vout: 0,
            sequence: 0xFFFFFFFF,
            script_sig: redeem_script
          }
        ],
        outputs: [%Output{script_pub_key: locking_script, value: 1_000}],
        locktime: 0
      }
      |> Transaction.sign_and_encode(private_key)

    assert "010000000197ca410de9ab568ab647984cd2b3f38284a8283ff261e26f96162abfb6358983000000006a473044022016bcad84e20bc6ec1a837c99ab552d8157c60c4ef5e9db3f2fe0c03b2ff8a78002205b404d67f4feb4fda8f86c16a0c8dac6530a54962ed961095ee7205b591dd4cc012103f0e5a53db9f85e5b2eecf677925ffe21dd1409bcfe9a0730404053599b0901e5ffffffff01e8030000000000001976a914fc8ca28ea75e45f538242c257e1f07fe19baa0f388ac00000000" ==
             signed_transaction
  end

  test "simplest testnet transaction yet, including a change address" do
    master_private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> PrivateKey.from_mnemonic_phrase()

    {:ok, spending_private_key} =
      master_private_key
      |> PrivateKey.from_derivation_path("m/44'/1'/0'/0/1")

    change_public_key_hash =
      master_private_key
      |> PrivateKey.from_derivation_path!("m/44'/1'/0'/1/1")
      |> PublicKey.from_private_key()
      |> PublicKeyHash.from_public_key()

    {:ok, target_public_key_hash, :p2pkh} =
      PublicKeyHash.from_address("mwKte669tM8ascBhvpw31phG2Ecauy8DUp")

#    IO.inspect(change_public_key_hash |> Binary.to_hex(), label: "change_public_key_hash")
#    IO.inspect(target_public_key_hash |> Binary.to_hex(), label: "target_public_key_hash")

    signed_transaction =
      %Transaction.Spec{}
      |> Transaction.Spec.add_input(
        txid: "f48648ab6adffe3b569383450a3279372a537c3be995c9e4e25f297d764e18d7",
        vout: 0,
        redeem_script: "76a914c39658833d83f2299416e697af2fb95a998853d388ac"
      )
      |> Transaction.Spec.add_output(
        script_pub_key: Script.Types.P2pkh.create(target_public_key_hash),
        value: 1_000
      )
      |> Transaction.Spec.add_output(
        script_pub_key: Script.Types.P2pkh.create(change_public_key_hash),
        value: 2_740_000
      )
      |> Transaction.Spec.sign_and_encode(spending_private_key)

    assert "0100000001d7184e767d295fe2e4c995e93b7c532a3779320a458393563bfedf6aab4886f4000000006a47304402205a66bb7fb5dde9736b2d653f0299129dc6575fc6a8544f1e8707a11555b44cd7022030ce0d69bfdcf459c4d6ac45b121a153ec728f6a9282539a674dc4f094843910012103f30d64f65d8c08aaf81a5f5ced3873d250a53371d83c0e4328bf74cb513778d8ffffffff0220cf2900000000001976a9140272853736f3dd09248055049ff15dff09d7f00f88ace8030000000000001976a914ad6a62e2d23d1c060897cd0cc79c42dad715e4c788ac00000000" ==
             signed_transaction
  end

  defp append_sighash(transaction, sighash) do
    <<transaction::bitstring, sighash::little-32>>
  end
end
