defmodule BitcoinLib.Script.Analyzer do
  alias BitcoinLib.Script.Opcodes.{BitwiseLogic, Constants, Crypto, Stack}

  @pub_key_hash_size 20
  @uncompressed_pub_key_size 65
  @key_hash_size 20
  @script_hash_size 32

  @zero Constants.Zero.v()
  @dup Stack.Dup.v()
  @equal BitwiseLogic.Equal.v()
  @equal_verify BitwiseLogic.EqualVerify.v()
  @hash160 Crypto.Hash160.v()
  @check_sig Crypto.CheckSig.v()

  # 41 <<_pub_key::520>> ac
  def identify(<<@uncompressed_pub_key_size::8, _pub_key::bitstring-520, @check_sig::8>>),
    do: :p2pk

  # 76 a9 14 <<_pub_key_hash::160>> 88 ac
  def identify(
        <<@dup::8, @hash160::8, @pub_key_hash_size::8, _pub_key_hash::bitstring-160,
          @equal_verify::8, @check_sig::8>>
      ),
      do: :p2pkh

  # a9 14 <<_script_hash::160>> 87
  def identify(<<@hash160::8, @pub_key_hash_size::8, _script_hash::bitstring-160, @equal>>),
    do: :p2sh

  # see https://bitcoincore.org/en/segwit_wallet_dev/#native-pay-to-witness-public-key-hash-p2wpkh
  # 00 14 <<_witness_script_hash::256>>
  def identify(<<@zero::8, @key_hash_size::8, _key_hash::160>>), do: :p2wpkh

  # see https://bitcoincore.org/en/segwit_wallet_dev/#native-pay-to-witness-script-hash-p2wsh
  # 00 20 <<_witness_script_hash::256>>
  def identify(<<@zero::8, @script_hash_size::8, _script_hash::256>>), do: :p2wsh

  def identify(script) when is_bitstring(script), do: :unknown
end
