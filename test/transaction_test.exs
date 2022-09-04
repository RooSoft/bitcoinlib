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
