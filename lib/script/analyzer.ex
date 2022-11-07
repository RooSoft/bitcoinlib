defmodule BitcoinLib.Script.Analyzer do
  @moduledoc """
  Based on that table https://i.stack.imgur.com/iXfVX.png

  useful links:
  - https://learnmeabitcoin.com/technical/scriptPubKey#standard-scripts
  """

  alias BitcoinLib.Script.Opcodes.{BitwiseLogic, Constants, Crypto, Data, Stack}

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
      {:p2pk, <<0x04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f::520>>}
  """

  # 41 <<_pub_key::520>> ac
  @spec identify(binary() | list()) :: {:p2pk | :p2pkh | :p2wpkh | :p2sh | :p2wsh, bitstring()}
  def identify(<<@uncompressed_pub_key_size::8, pub_key::bitstring-520, @check_sig::8>>),
    do: {:p2pk, pub_key}

  def identify([%Data{value: <<pub_key::bitstring-520>>}, %Crypto.CheckSig{}]),
    do: {:p2pk, pub_key}

  # address example: 1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2
  # 76 a9 14 <<_pub_key_hash::160>> 88 ac
  def identify(
        <<@dup::8, @hash160::8, @pub_key_hash_size::8, pub_key_hash::bitstring-160,
          @equal_verify::8, @check_sig::8>>
      ),
      do: {:p2pkh, pub_key_hash}

  def identify([
        %BitcoinLib.Script.Opcodes.Stack.Dup{},
        %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
        %BitcoinLib.Script.Opcodes.Data{value: <<pub_key_hash::bitstring-160>>},
        %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
        %BitcoinLib.Script.Opcodes.Crypto.CheckSig{}
      ]),
      do: {:p2pkh, pub_key_hash}

  # address example: 3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy
  # a9 14 <<_script_hash::160>> 87
  def identify(<<@hash160::8, @pub_key_hash_size::8, script_hash::bitstring-160, @equal>>),
    do: {:p2sh, script_hash}

  def identify([
        %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
        %BitcoinLib.Script.Opcodes.Data{value: <<script_hash::bitstring-160>>},
        %BitcoinLib.Script.Opcodes.BitwiseLogic.Equal{}
      ]),
      do: {:p2sh, script_hash}

  # see https://bitcoincore.org/en/segwit_wallet_dev/#native-pay-to-witness-public-key-hash-p2wpkh
  # address example: bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq
  # 00 14 <<_witness_script_hash::256>>
  def identify(<<@zero::8, @key_hash_size::8, key_hash::160>>), do: {:p2wpkh, key_hash}

  def identify([
        %BitcoinLib.Script.Opcodes.Constants.Zero{},
        %BitcoinLib.Script.Opcodes.Data{value: <<key_hash::bitstring-160>>}
      ]),
      do: {:p2wpkh, key_hash}

  # see https://bitcoincore.org/en/segwit_wallet_dev/#native-pay-to-witness-script-hash-p2wsh
  # address example: bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq
  # 00 20 <<_witness_script_hash::256>>
  def identify(<<@zero::8, @script_hash_size::8, script_hash::bitstring-256>>),
    do: {:p2wsh, script_hash}

  def identify([
        %BitcoinLib.Script.Opcodes.Constants.Zero{},
        %BitcoinLib.Script.Opcodes.Data{value: <<script_hash::bitstring-256>>}
      ]),
      do: {:p2wsh, script_hash}

  def identify(script) when is_bitstring(script), do: :unknown
end
