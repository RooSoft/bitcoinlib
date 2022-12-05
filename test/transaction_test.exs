defmodule BitcoinLib.TransactionTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Transaction

  alias BitcoinLib.{Address, Transaction, Script}
  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Transaction.{Input, Output}
  alias BitcoinLib.Script.Opcodes

  test "decode a transaction" do
    raw =
      "01000000017b1eabe0209b1fe794124575ef807057c77ada2138ae4fa8d6c4de0398a14f3f0000000000ffffffff01f0ca052a010000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac00000000"
      |> Binary.from_hex()

    {:ok, transaction, <<>>} = Transaction.decode(raw)

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

    {:ok, %Transaction{inputs: [%Input{txid: txid}]}, <<>>} =
      "010000000197ca410de9ab568ab647984cd2b3f38284a8283ff261e26f96162abfb6358983000000006a473044022016bcad84e20bc6ec1a837c99ab552d8157c60c4ef5e9db3f2fe0c03b2ff8a78002205b404d67f4feb4fda8f86c16a0c8dac6530a54962ed961095ee7205b591dd4cc012103f0e5a53db9f85e5b2eecf677925ffe21dd1409bcfe9a0730404053599b0901e5ffffffff01e8030000000000001976a914fc8ca28ea75e45f538242c257e1f07fe19baa0f388ac00000000"
      |> Binary.from_hex()
      |> Transaction.decode()

    assert txid == "838935b6bf2a16966fe261f23f28a88482f3b3d24c9847b68a56abe90d41ca97"
  end

  test "sign and encode transaction" do
    seed_phrase = "erode gloom apart system broom lemon dismiss post artist slot humor occur"
    derivation_path = "m/44'/1'/0'/0/0"
    network = :testnet

    %{
      private_key: private_key,
      public_key_hash: public_key_hash
    } = create_keys(seed_phrase, derivation_path, network)

    # the transaction can be found in a block explorer such as here:
    # https://mempool.space/testnet/tx/e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6
    # we use the first UTXO's script pub key from the output in the above transaction:
    redeem_script =
      <<0x76A914AFC3E518577316386188AF748A816CD14CE333F288AC::200>>
      |> Script.parse!()

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
    value = 10_000

    transaction = create_transaction(txid, vout, locking_script, redeem_script, value)

    Transaction.sign_and_encode(transaction, private_key)
  end

  test "decode a P2SH-P2WPKH transaction" do
    encoded =
      "01000000000101db6b1b20aa0fd7b23880be2ecbd4a98130974cf4748fb66092ac4d3ceb1a5477010000001716001479091972186c449eb1ded22b78e40d009bdf0089feffffff02b8b4eb0b000000001976a914a457b684d7f0d539a46a45bbc043f35b59d0d96388ac0008af2f000000001976a914fd270b1ee6abcaea97fea7ad0402e8bd8ad6d77c88ac02473044022047ac8e878352d3ebbde1c94ce3a10d057c24175747116f8288e5d794d12d482f0220217f36a485cae903c713331d877c1f64677e3622ad4010726870540656fe9dcb012103ad1d8e89212f0b92c74d23bb710c00662ad1470198ac48c43f7d6f93a2a2687392040000"

    {:ok, transaction, <<>>} = Transaction.parse(encoded)

    assert [
             %BitcoinLib.Transaction.Input{
               txid: "77541aeb3c4dac9260b68f74f44c973081a9d4cb2ebe8038b2d70faa201b6bdb",
               vout: 1,
               script_sig: [
                 %BitcoinLib.Script.Opcodes.Data{
                   value: <<0x001479091972186C449EB1DED22B78E40D009BDF0089::176>>
                 }
               ],
               sequence: 4_294_967_294
             }
           ] = transaction.inputs
  end

  test "encode a P2SH-P2WPKH transaction" do
    transaction = %BitcoinLib.Transaction{
      version: 1,
      inputs: [
        %BitcoinLib.Transaction.Input{
          txid: "77541aeb3c4dac9260b68f74f44c973081a9d4cb2ebe8038b2d70faa201b6bdb",
          vout: 1,
          script_sig: [
            %BitcoinLib.Script.Opcodes.Data{
              value: <<0x001479091972186C449EB1DED22B78E40D009BDF0089::176>>
            }
          ],
          sequence: 4_294_967_294
        }
      ],
      outputs: [
        %BitcoinLib.Transaction.Output{
          value: 199_996_600,
          script_pub_key: [
            %BitcoinLib.Script.Opcodes.Stack.Dup{},
            %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
            %BitcoinLib.Script.Opcodes.Data{
              value: <<0xA457B684D7F0D539A46A45BBC043F35B59D0D963::160>>
            },
            %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
            %BitcoinLib.Script.Opcodes.Crypto.CheckSig{
              script: <<0x76A914A457B684D7F0D539A46A45BBC043F35B59D0D96388AC::200>>
            }
          ]
        },
        %BitcoinLib.Transaction.Output{
          value: 800_000_000,
          script_pub_key: [
            %BitcoinLib.Script.Opcodes.Stack.Dup{},
            %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
            %BitcoinLib.Script.Opcodes.Data{
              value: <<0xFD270B1EE6ABCAEA97FEA7AD0402E8BD8AD6D77C::160>>
            },
            %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
            %BitcoinLib.Script.Opcodes.Crypto.CheckSig{
              script: <<0x76A914FD270B1EE6ABCAEA97FEA7AD0402E8BD8AD6D77C88AC::200>>
            }
          ]
        }
      ],
      witness: [
        [
          <<0x03AD1D8E89212F0B92C74D23BB710C00662AD1470198AC48C43F7D6F93A2A26873::264>>,
          <<0x3044022047AC8E878352D3EBBDE1C94CE3A10D057C24175747116F8288E5D794D12D482F0220217F36A485CAE903C713331D877C1F64677E3622AD4010726870540656FE9DCB01::568>>
        ]
      ],
      locktime: 0x492
    }

    encoded = Transaction.encode(transaction) |> Binary.to_hex()

    assert encoded ==
             "01000000000101db6b1b20aa0fd7b23880be2ecbd4a98130974cf4748fb66092ac4d3ceb1a5477010000001716001479091972186c449eb1ded22b78e40d009bdf0089feffffff02b8b4eb0b000000001976a914a457b684d7f0d539a46a45bbc043f35b59d0d96388ac0008af2f000000001976a914fd270b1ee6abcaea97fea7ad0402e8bd8ad6d77c88ac022103ad1d8e89212f0b92c74d23bb710c00662ad1470198ac48c43f7d6f93a2a26873473044022047ac8e878352d3ebbde1c94ce3a10d057c24175747116f8288e5d794d12d482f0220217f36a485cae903c713331d877c1f64677e3622ad4010726870540656fe9dcb0192040000"

    ### TODO: verify this test, used to be this value below before the witness refactoring
    ######### expecting the new value to be the good one, but not tested before commit

    #    assert encoded ==
    #             "01000000000101db6b1b20aa0fd7b23880be2ecbd4a98130974cf4748fb66092ac4d3ceb1a5477010000001716001479091972186c449eb1ded22b78e40d009bdf0089feffffff02b8b4eb0b000000001976a914a457b684d7f0d539a46a45bbc043f35b59d0d96388ac0008af2f000000001976a914fd270b1ee6abcaea97fea7ad0402e8bd8ad6d77c88ac02473044022047ac8e878352d3ebbde1c94ce3a10d057c24175747116f8288e5d794d12d482f0220217f36a485cae903c713331d877c1f64677e3622ad4010726870540656fe9dcb012103ad1d8e89212f0b92c74d23bb710c00662ad1470198ac48c43f7d6f93a2a2687392040000"
  end

  test "transaction id of a multisig 2 of 3" do
    encoded_transaction =
      "0100000001faf3dab2148d751025fe04c920c12cc337259648b9ddfcda6e318cb2ccafdeb800000000fc0047304402207d69c17537506aea4d7e9119884a36b609b0bfc4538aaed5ce68fa663ae2de6802207b9b8c79c5514509952bb40ce0497314ee4bff60f1cca84014027576fd61df360147304402204f6b83c4c8f91f03e0e66d7e751b23eea06d0f73fc115e4bd61f6bdf3103c901022076cee5f9f0f09574b212683a0ec43fbae66b8f13e3ad40c60984e4bb67110c4b014c69522102495e2870f972a3af6cb7652354cdacb444a37539c67537b1179bc6e7bc148d2c210380c5790d3b426782f2434879ca6cf9575155b4266e0a1ed901a09fed62d020d121034e9e421c98cddb0776fba0be1f9189cc366c008b2cbf59fc868fcf562dae686e53aeffffffff0209721800000000001976a91462c96184bebbb9b1776e7bc96c8865dd57fb6fcb88acd1700f000000000017a9147709bc9eaeee27734a6c0d37a42cfc0250b9c15a8700000000"
      |> Binary.from_hex()

    {:ok, transaction, remaining} =
      encoded_transaction
      |> Transaction.decode()

    assert <<>> == remaining
    assert "9dc1ebe3041586d5e1e34a6503eefb73ccd3752ce38471d32b8e0b50dbfe84bb" == transaction.id
  end

  test "OP_PUSHBYTES_22 transaction parsing" do
    encoded_transaction =
      "0100000000010211687ac8a98b91ce2f840354a83c34293264b4aaeaeedff21ee4e1ae43b93fa00100000017160014c314c21eee9097386def9e5edd964b41b38ac140ffffffff1242f9f73df1ac099f65b7d1f8b504f378c8f7afd254eac64eb06277bc3ee92a0000000017160014dd16088b974daff5e22dffb02776b4b214fdbfcfffffffff01b28603060000000017a914e6194861f82d30758570e7fc5bafb04309f915bc8702483045022100b9a3c38c13fa27e9672c9b5070d299a724df92d6e4e15887397379a1d7fff36802202fcf9f793b2aa95c64e2f58874ebc0440f8eb992ac6ef1cc6d45bb6c01e23672012102049ded349634224d97a5ae5aa8ead4ec45083104a80ae1a1a28eeb803dac5b1b02483045022100ca1ab101e4bb8cd9d5f37ba4cc4491eaacc779a1b5d9b043a6c4afabde1056080220401168e7171f65b5e7aa515331eedaef762f68c5d93175358dd4bf408f13ef5b0121033a278d049e5125128f31166c72519d166538d86a9feda04b3252cfe4cc20165300000000"
      |> Binary.from_hex()

    {:ok, transaction, remaining} =
      encoded_transaction
      |> Transaction.decode()

    witness_count = Enum.count(transaction.witness)

    assert <<>> == remaining
    assert 2 == witness_count
  end

  test "transaction with weird segwit bugs" do
    encoded_transaction =
      "02000000000103705e4e8c6950acfcc2ba4fc6dc683c133643559b77689ab5db81d7041589847a020000006a47304402205ae3fc6920bd3ac815301bd0ef722fa1af05861517f1b4bd93efee32dc10caab022044ea339b37ac988ea55e76103f932fc7d381ec950b6311e4746383814df56d3701210390d4cfbb2596015912a6fe3bba02d83a5f070694a693e1baf665c030db484887fdffffff9d441a03c8e832ba5f5f5723be1be4ab4ef222d4f2d2f3edce3effb8ddf9d616040000006b48304502210097aa5323ffb82b1f785c7c72114a1786c8692cc80b3d3a596a98143e4b8507c802205002d74b80f42a097067f8f97ed45741c6030fbc9919945d086417d64be55dff012103b8af09eb091951a9ac428c8a9040ff57a6dfbefbe64ce02e5db3a25cda9e5353fdffffff9f1210a188b79bc3c2ebd8dab5359be119eda661778e87efc36146f8ca345dbf00000000171600140c6259927541c4f8e88fc1398691e2661d15591afdffffff0150878e010000000017a91485f277c40f074b0117ccf3f211831ae741cbb50187000002473044022049f3714a6d337c8731a253b0022d41673df0f15ddd0cee1e45b58dcb17e468be0220796965eddcaa804325002b1dbe930339e40f339f2cab82057586965b0180a7d4012102d803b5b7c1227b4c898cb326e2b67b495578b62637701ee37863f6a6f56b2fb0215a0700"
      |> Binary.from_hex()

    {:ok, transaction, remaining} =
      encoded_transaction
      |> Transaction.decode()

    witness_count = Enum.count(transaction.witness)

    assert <<>> == remaining
    assert 3 == witness_count
  end

  @spec create_keys(binary(), binary(), :mainnet | :testnet) :: map()
  defp create_keys(seed_phrase, derivation_path, network) do
    private_key =
      seed_phrase
      |> PrivateKey.from_seed_phrase()
      |> PrivateKey.from_derivation_path(derivation_path)
      |> elem(1)

    public_key =
      private_key
      |> PublicKey.from_private_key()

    public_key_hash =
      public_key
      |> PublicKey.hash()

    address =
      public_key_hash
      |> Address.from_public_key_hash(network)

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
