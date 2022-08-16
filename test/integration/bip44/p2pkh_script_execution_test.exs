defmodule BitcoinLib.Test.Integration.Bip44.P2pkhScriptExecutionTest do
  @moduledoc """
  Based on this transaction https://mempool.space/tx/d0e156802f58009853472d147afbb8427e3325887e3024fd1792950d7fa2928d
  """
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.{PublicHash}
  alias BitcoinLib.Key.HD.{ExtendedPrivate, MnemonicSeed}

  alias BitcoinLib.Script
  alias BitcoinLib.Script.Opcodes.{Stack, Crypto, BitwiseLogic}

  @pub_key_hash_size 0x14

  @dup Stack.Dup.v()
  @hash_160 Crypto.Hash160.v()
  @equal_verify BitwiseLogic.EqualVerify.v()
  @check_sig Crypto.CheckSig.v()

  test "execute a P2PKH script" do
    extended_private_key =
      "rally celery split order almost twenty ignore record legend learn chaos decade"
      |> MnemonicSeed.to_seed()
      |> ExtendedPrivate.from_seed()
      |> ExtendedPrivate.from_derivation_path!("m/44'/0'/0'/0/0")

    public_key =
      extended_private_key
      |> BitcoinLib.Key.HD.ExtendedPublic.from_private_key()
      |> Map.get(:key)

    private_key = extended_private_key |> Map.get(:key)

    public_key_hash =
      public_key |> PublicHash.from_public_key()

    # 76 a9 14 725ebac06343111227573d0b5287954ef9b88aae 88 ac
    # OP_DUP OP_HASH160 OP_PUSHBYTES_20 725ebac06343111227573d0b5287954ef9b88aae OP_EQUALVERIFY OP_CHECKSIG
    script =
      <<@dup::8, @hash_160::8, @pub_key_hash_size::8, public_key_hash::bitstring-160,
        @equal_verify::8, @check_sig::8>>

    hex_script = script |> Binary.to_hex()

    script_sig = BitcoinLib.Crypto.Secp256k1.sign(hex_script, private_key)

    result = Script.execute(script, [public_key, script_sig])

    assert {:ok, true} = result
  end
end
