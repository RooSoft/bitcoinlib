defmodule BitcoinLib.TransactionTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Transaction

  alias BitcoinLib.Key.{PrivateKey, PublicKey, PublicKeyHash}
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Input, Output}
  alias BitcoinLib.Script.Opcodes
  alias BitcoinLib.Script

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
             script_sig: [],
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

  test "decode a testnet transaction" do
    # txid = e3600a1bc8a564bb29a79a38ec8ff456edf3bed757112ec70541cf2e3500d221

    {:ok, %Transaction{inputs: [%Input{txid: txid}]}} =
      "010000000197ca410de9ab568ab647984cd2b3f38284a8283ff261e26f96162abfb6358983000000006a473044022016bcad84e20bc6ec1a837c99ab552d8157c60c4ef5e9db3f2fe0c03b2ff8a78002205b404d67f4feb4fda8f86c16a0c8dac6530a54962ed961095ee7205b591dd4cc012103f0e5a53db9f85e5b2eecf677925ffe21dd1409bcfe9a0730404053599b0901e5ffffffff01e8030000000000001976a914fc8ca28ea75e45f538242c257e1f07fe19baa0f388ac00000000"
      |> Binary.from_hex()
      |> Transaction.decode()

    assert txid == "838935b6bf2a16966fe261f23f28a88482f3b3d24c9847b68a56abe90d41ca97"
  end

  test "sign and encode transaction" do
    mnemonics = derivation_path = "m/44'/1'/0'/0/0"
    network = :testnet
    address_type = :p2pkh

    %{
      private_key: private_key,
      public_key_hash: public_key_hash
    } = create_keys(mnemonics, derivation_path, network, address_type)

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

    txid = "e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6"
    vout = 0
    value = 10000

    transaction = create_transaction(txid, vout, locking_script, redeem_script, value)

    Transaction.sign_and_encode(transaction, private_key)
  end

  @spec create_keys(binary(), binary(), :mainnet | :testnet, :p2pkh) :: map()
  defp create_keys(mnemonics, derivation_path, network, address_type) do
    private_key =
      mnemonics
      |> PrivateKey.from_mnemonic_phrase()
      |> PrivateKey.from_derivation_path(derivation_path)
      |> elem(1)

    public_key =
      private_key
      |> PublicKey.from_private_key()

    public_key_hash =
      public_key
      |> PublicKeyHash.from_public_key()

    address =
      public_key_hash
      |> BitcoinLib.Key.Address.from_public_key_hash(address_type, network)

    %{
      private_key: private_key,
      public_key: public_key,
      public_key_hash: public_key_hash,
      address: address
    }
  end

  defp create_transaction(txid, vout, locking_script, redeem_script, value) do
    %Transaction{
      version: 1,
      inputs: [
        %Input{
          txid: txid,
          vout: vout,
          sequence: 0xFFFFFFFF,
          script_sig: redeem_script
        }
      ],
      outputs: [%Output{script_pub_key: locking_script, value: value}],
      locktime: 0
    }
  end
end
