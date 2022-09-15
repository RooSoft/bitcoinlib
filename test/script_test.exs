defmodule BitcoinLib.ScriptTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Script

  alias BitcoinLib.Key.{PrivateKey, PublicKey, PublicKeyHash}
  alias BitcoinLib.Script
  alias BitcoinLib.Script.Opcodes.{BitwiseLogic, Constants, Crypto, Data, Stack}

  @dup Stack.Dup.v()
  @hash_160 Crypto.Hash160.v()
  @equal BitwiseLogic.Equal.v()
  @equal_verify BitwiseLogic.EqualVerify.v()
  @check_sig Crypto.CheckSig.v()

  test "script duplicating the input and verifying both resulting elements are the same" do
    input = [0x3]
    script = <<@dup::8, @equal::8>>

    {:ok, result} = Script.execute(script, input)

    assert true == result
  end

  test "parse a standard transaction to bitcoin address (pay-to-pubkey-hash)" do
    private_key = %PrivateKey{key: PrivateKey.generate().raw}
    public_key = PublicKey.from_private_key(private_key)
    public_key_hash = PublicKeyHash.from_public_key(public_key)

    pub_key_hash_size = 0x14

    # 76 a9 14 725ebac06343111227573d0b5287954ef9b88aae 88 ac
    # OP_DUP OP_HASH160 OP_PUSHBYTES_20 725ebac06343111227573d0b5287954ef9b88aae OP_EQUALVERIFY OP_CHECKSIG
    script =
      <<@dup::8, @hash_160::8, pub_key_hash_size::8, public_key_hash::bitstring-160,
        @equal_verify::8, @check_sig::8>>

    sig = PrivateKey.sign_message(script |> Binary.to_hex(), private_key)

    {:ok, result} = Script.execute(script, [public_key.key, sig])

    assert true == result
  end

  test "identify a script as a P2SH" do
    script = <<0xA9143545E6E33B832C47050F24D3EEB93C9C03948BC787::184>>

    script_type = Script.identify(script)

    assert :p2sh == script_type
  end

  test "parse the simplest of scripts" do
    script = <<0>>

    {:ok, opcodes} = Script.parse(script)

    assert 1 = Enum.count(opcodes)
  end

  test "parse a redeem script" do
    redeem_script =
      <<0x5221029583BF39AE0A609747AD199ADDD634FA6108559D6C5CD39B4C2183F1AB96E07F2102DAB61FF49A14DB6A7D02B0CD1FBB78FC4B18312B5B4E54DAE4DBA2FBFEF536D752AF::568>>

    opcodes = Script.parse!(redeem_script)

    assert [
             %Constants.Two{},
             %Data{
               value:
                 <<0x029583BF39AE0A609747AD199ADDD634FA6108559D6C5CD39B4C2183F1AB96E07F::264>>
             },
             %Data{
               value:
                 <<0x02DAB61FF49A14DB6A7D02B0CD1FBB78FC4B18312B5B4E54DAE4DBA2FBFEF536D7::264>>
             },
             %Constants.Two{},
             %Crypto.CheckMultiSigVerify{}
           ] = opcodes
  end

  test "parse a script pub key" do
    script_pub_key = <<0xA91429CA74F8A08F81999428185C97B5D852E4063F6187::184>>

    opcodes = Script.parse!(script_pub_key)

    assert [
             %Crypto.Hash160{},
             %Data{value: <<0x29CA74F8A08F81999428185C97B5D852E4063F61::160>>},
             %BitwiseLogic.Equal{}
           ] = opcodes
  end
end
