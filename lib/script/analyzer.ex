defmodule BitcoinLib.Script.Analyzer do
  @moduledoc """
  Based on that table https://i.stack.imgur.com/iXfVX.png

  useful links:
  - https://learnmeabitcoin.com/technical/scriptPubKey#standard-scripts
  """

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

  @doc """
  Identify a script in either binary or opcode list forms

  ## Examples
    iex> <<0x4104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC::536>>
    ...> |> BitcoinLib.Script.Analyzer.identify()
    :p2pk
  """

  # 41 <<_pub_key::520>> ac
  @spec identify(binary()) :: atom()
  def identify(<<@uncompressed_pub_key_size::8, _pub_key::bitstring-520, @check_sig::8>>),
    do: :p2pk

  # address example: 1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2
  # 76 a9 14 <<_pub_key_hash::160>> 88 ac
  @spec identify(binary()) :: atom()
  def identify(
        <<@dup::8, @hash160::8, @pub_key_hash_size::8, _pub_key_hash::bitstring-160,
          @equal_verify::8, @check_sig::8>>
      ),
      do: :p2pkh

  @spec identify(list()) :: atom()
  def identify([
        %BitcoinLib.Script.Opcodes.Stack.Dup{},
        %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
        %BitcoinLib.Script.Opcodes.Data{value: <<_::160>>},
        %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
        %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<_::200>>}
      ]),
      do: :p2pkh

  # address example: 3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy
  # a9 14 <<_script_hash::160>> 87
  @spec identify(binary()) :: atom()
  def identify(<<@hash160::8, @pub_key_hash_size::8, _script_hash::bitstring-160, @equal>>),
    do: :p2sh

  @spec identify(list()) :: atom()
  def identify([
        %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
        %BitcoinLib.Script.Opcodes.Data{value: <<_::160>>},
        %BitcoinLib.Script.Opcodes.BitwiseLogic.Equal{}
      ]),
      do: :p2sh

  # see https://bitcoincore.org/en/segwit_wallet_dev/#native-pay-to-witness-public-key-hash-p2wpkh
  # address example: bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq
  # 00 14 <<_witness_script_hash::256>>
  @spec identify(binary()) :: atom()
  def identify(<<@zero::8, @key_hash_size::8, _key_hash::160>>), do: :p2wpkh

  @spec identify(list()) :: atom()
  def identify([
        %BitcoinLib.Script.Opcodes.Constants.Zero{},
        %BitcoinLib.Script.Opcodes.Data{value: <<_::160>>}
      ]),
      do: :p2wpkh

  # see https://bitcoincore.org/en/segwit_wallet_dev/#native-pay-to-witness-script-hash-p2wsh
  # address example: bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq
  # 00 20 <<_witness_script_hash::256>>
  @spec identify(binary()) :: atom()
  def identify(<<@zero::8, @script_hash_size::8, _script_hash::256>>), do: :p2wsh

  @spec identify(list()) :: atom()
  def identify([
        %BitcoinLib.Script.Opcodes.Constants.Zero{},
        %BitcoinLib.Script.Opcodes.Data{value: <<_::256>>}
      ]),
      do: :p2wsh

  def identify(script) when is_bitstring(script), do: :unknown
end
