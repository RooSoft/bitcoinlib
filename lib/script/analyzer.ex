defmodule BitcoinLib.Script.Analyzer do
  alias BitcoinLib.Script.Opcodes.{BitwiseLogic, Crypto, Stack}

  @pub_key_hash_size 20

  @dup Stack.Dup.v()
  @equal_verify BitwiseLogic.EqualVerify.v()
  @hash160 Crypto.Hash160.v()
  @check_sig Crypto.CheckSig.v()

  def identify(
        <<@dup::8, @hash160::8, @pub_key_hash_size::8, _pub_key_hash::bitstring-160,
          @equal_verify::8, @check_sig::8>>
      ),
      do: :p2pkh

  def identify(script) when is_bitstring(script), do: :unknown
end
