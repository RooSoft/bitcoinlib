defmodule BitcoinLib.Script.AnalyzerTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Script.Analyzer

  alias BitcoinLib.Script.Analyzer
  alias BitcoinLib.Script.Opcodes

  test "identify a P2PK script in binary format" do
    script =
      <<0x4104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC::536>>

    {script_type, public_key} = Analyzer.identify(script)

    assert :p2pk == script_type

    assert <<0x04678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5F::520>> ==
             public_key
  end

  test "identify a P2PK script in opcode list format" do
    script = [
      %Opcodes.Data{
        value:
          <<0x04678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5F::520>>
      },
      %Opcodes.Crypto.CheckSig{}
    ]

    {script_type, public_key} = Analyzer.identify(script)

    assert :p2pk == script_type

    assert <<0x04678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5F::520>> ==
             public_key
  end

  test "identify a P2PKH script in binary format" do
    script = <<0x76A914725EBAC06343111227573D0B5287954EF9B88AAE88AC::200>>

    {script_type, public_key_hash} = Analyzer.identify(script)

    assert :p2pkh == script_type
    assert <<0x725EBAC06343111227573D0B5287954EF9B88AAE::160>> == public_key_hash
  end

  test "identify a P2PKH script in opcode list format" do
    script = [
      %Opcodes.Stack.Dup{},
      %Opcodes.Crypto.Hash160{},
      %Opcodes.Data{value: <<0x725EBAC06343111227573D0B5287954EF9B88AAE::160>>},
      %Opcodes.BitwiseLogic.EqualVerify{},
      %Opcodes.Crypto.CheckSig{}
    ]

    {script_type, public_key_hash} = Analyzer.identify(script)

    assert :p2pkh == script_type
    assert <<0x725EBAC06343111227573D0B5287954EF9B88AAE::160>> == public_key_hash
  end

  test "identify a P2SH script in binary format" do
    script = <<0xA9143545E6E33B832C47050F24D3EEB93C9C03948BC787::184>>

    {script_type, script_hash} = Analyzer.identify(script)

    assert :p2sh == script_type
    assert <<0x3545E6E33B832C47050F24D3EEB93C9C03948BC7::160>> == script_hash
  end

  test "identify a P2SH script in opcode list format" do
    script = [
      %Opcodes.Crypto.Hash160{},
      %Opcodes.Data{value: <<0x3545E6E33B832C47050F24D3EEB93C9C03948BC7::160>>},
      %Opcodes.BitwiseLogic.Equal{}
    ]

    {script_type, script_hash} = Analyzer.identify(script)

    assert :p2sh == script_type
    assert <<0x3545E6E33B832C47050F24D3EEB93C9C03948BC7::160>> == script_hash
  end

  test "identify garbage as an unknown script" do
    script = <<0>>

    script_type = Analyzer.identify(script)

    assert :unknown == script_type
  end
end
