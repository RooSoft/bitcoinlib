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
    pub_key_hash = 0x12AB8DC588CA9D5787DDE7EB29569DA63C3A238C

    # 76 a9 14 12ab8dc588ca9d5787dde7eb29569da63c3a238c 88 ac
    # OP_DUP OP_HASH160 OP_PUSHBYTES_20 12ab8dc588ca9d5787dde7eb29569da63c3a238c OP_EQUALVERIFY OP_CHECKSIG
    script =
      <<@dup::8, @hash_160::8, pub_key_hash_size::8, pub_key_hash::160, @equal_verify::8,
        @check_sig::8>>

    # can probably be gotten by https://hexdocs.pm/curvy/Curvy.html#sign/3
    sig =
      "304502203F004EEED0CEF2715643E2F25A27A28F3C578E94C7F0F6A4DF104E7D163F7F8F022100B8B248C1CFD8F77A0365107A9511D759B7544D979DD152A955C867AFAC0EF78601"

    pub_key =
      "044D05240CFBD8A2786EDA9DADD520C1609B8593FF8641018D57703D02BA687CF2F187F0CEE2221C3AFB1B5FF7888CACED2423916B61444666CA1216F26181398C"

    {:error, message} = Script.execute(script, [sig, pub_key])

    assert message =~ "the script is invalid, it doesn't pass the OP_VERIFY test with 0 as the top stack value"
  end
end
