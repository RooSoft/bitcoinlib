defmodule BitcoinLib.ScriptTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Script

  alias BitcoinLib.Script
  alias BitcoinLib.Script.Opcodes.{Stack, Crypto, BitwiseLogic}

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
    pub_key_hash_size = 0x14
    pub_key_hash = <<0x725EBAC06343111227573D0B5287954EF9B88AAE::160>>

    # 76 a9 14 725ebac06343111227573d0b5287954ef9b88aae 88 ac
    # OP_DUP OP_HASH160 OP_PUSHBYTES_20 725ebac06343111227573d0b5287954ef9b88aae OP_EQUALVERIFY OP_CHECKSIG
    script =
      <<@dup::8, @hash_160::8, pub_key_hash_size::8, pub_key_hash::bitstring-160,
        @equal_verify::8, @check_sig::8>>

    pub_key = <<0x03EB181FB7B5CF63D82307188B20828B83008F2D2511E5C6EDCBE171C63DD2CBC1::264>>

    sig =
      <<0x3045022100A9A1CEB7B278D7EC33BEAEC3A8D53A466C5553E0A218DECD7357703E9C25172E022053555BB91729EB9F1488DFB286A949D481A4D7D8735CB92BBBE92A24D4532D30::568>>

    {:ok, result} = Script.execute(script, [pub_key, sig])

    assert true == result
  end
end
