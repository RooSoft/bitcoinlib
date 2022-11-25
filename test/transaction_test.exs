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
    value = 10000

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
        <<0x03AD1D8E89212F0B92C74D23BB710C00662AD1470198AC48C43F7D6F93A2A26873::264>>,
        <<0x3044022047AC8E878352D3EBBDE1C94CE3A10D057C24175747116F8288E5D794D12D482F0220217F36A485CAE903C713331D877C1F64677E3622AD4010726870540656FE9DCB01::568>>
      ],
      locktime: 0x492
    }

    encoded = Transaction.encode(transaction) |> Binary.to_hex()

    assert encoded ==
             "01000000000101db6b1b20aa0fd7b23880be2ecbd4a98130974cf4748fb66092ac4d3ceb1a5477010000001716001479091972186c449eb1ded22b78e40d009bdf0089feffffff02b8b4eb0b000000001976a914a457b684d7f0d539a46a45bbc043f35b59d0d96388ac0008af2f000000001976a914fd270b1ee6abcaea97fea7ad0402e8bd8ad6d77c88ac02473044022047ac8e878352d3ebbde1c94ce3a10d057c24175747116f8288e5d794d12d482f0220217f36a485cae903c713331d877c1f64677e3622ad4010726870540656fe9dcb012103ad1d8e89212f0b92c74d23bb710c00662ad1470198ac48c43f7d6f93a2a2687392040000"
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
