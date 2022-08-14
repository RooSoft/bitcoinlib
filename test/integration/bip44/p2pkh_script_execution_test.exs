defmodule BitcoinLib.Test.Integration.Bip44.P2pkhScriptExecutionTest do
  @moduledoc """
  Based on this transaction https://mempool.space/tx/d0e156802f58009853472d147afbb8427e3325887e3024fd1792950d7fa2928d
  """
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.{PublicHash}
  alias BitcoinLib.Key.HD.{ExtendedPrivate, ExtendedPublic, MnemonicSeed}

  alias BitcoinLib.Script
  alias BitcoinLib.Script.Opcodes.{Stack, Crypto, BitwiseLogic}

  @pub_key_hash_size 0x14

  @dup Stack.Dup.v()
  @hash_160 Crypto.Hash160.v()
  @equal_verify BitwiseLogic.EqualVerify.v()
  @check_sig Crypto.CheckSig.v()

  test "execute a P2PKH script" do
    private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> MnemonicSeed.to_seed()
      |> ExtendedPrivate.from_seed()

    #### remove later
    assert 0xD6EAD233E06C068585976B5C8373861D77E7F030EC452E65EE81C85FA6906970 = private_key.key

    public_key =
      private_key
      |> ExtendedPrivate.from_derivation_path!("m/44'/0'/0'/0/0")
      |> ExtendedPublic.from_private_key()

    public_key_hash =
      public_key.key
      |> PublicHash.from_public_key()

    public_key_hash_size = @pub_key_hash_size

    # 76 a9 14 725ebac06343111227573d0b5287954ef9b88aae 88 ac
    # OP_DUP OP_HASH160 OP_PUSHBYTES_20 725ebac06343111227573d0b5287954ef9b88aae OP_EQUALVERIFY OP_CHECKSIG
    script =
      <<@dup::8, @hash_160::8, public_key_hash_size::8, public_key_hash::160, @equal_verify::8,
        @check_sig::8>>

    script_sig =
      BitcoinLib.Crypto.Secp256k1.sign(
        script |> Binary.to_hex(),
        private_key.key |> Integer.to_string(16)
      )

    result =
      Script.execute(script, [
        public_key.key,
        script_sig
      ])

    assert {:ok, true} = result

    assert 0x3EB181FB7B5CF63D82307188B20828B83008F2D2511E5C6EDCBE171C63DD2CBC1 = public_key.key

    assert 0x725EBAC06343111227573D0B5287954EF9B88AAE = public_key_hash

    assert <<0x76, 0xA9, 0x14, 0x72, 0x5E, 0xBA, 0xC0, 0x63, 0x43, 0x11, 0x12, 0x27, 0x57, 0x3D,
             0xB, 0x52, 0x87, 0x95, 0x4E, 0xF9, 0xB8, 0x8A, 0xAE, 0x88, 0xAC>> = script

    assert 0x3EB181FB7B5CF63D82307188B20828B83008F2D2511E5C6EDCBE171C63DD2CBC1 = public_key.key

    assert "3044022056b208c51d456abb6ac28a08d2dc289a78e575c2f21e70afaa636684a24b7b6602207836285645dac174820e7dd47d1c989745f985eefe34b18c26648d43d34f88df" =
             script_sig
  end
end
