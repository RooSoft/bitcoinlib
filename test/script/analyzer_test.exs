defmodule BitcoinLib.Script.AnalyzerTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Script.Analyzer

  test "identify a P2PK script" do
    script =
      <<0x4104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC::536>>

    script_type = Analyzer.identify(script)

    assert :p2pk == script_type
  end

  test "identify a P2PKH script" do
    script = <<0x76A914725EBAC06343111227573D0B5287954EF9B88AAE88AC::200>>

    script_type = Analyzer.identify(script)

    assert :p2pkh == script_type
  end

  test "identify a P2SH script" do
    script = <<0xA9143545E6E33B832C47050F24D3EEB93C9C03948BC787::184>>

    script_type = Analyzer.identify(script)

    assert :p2sh == script_type
  end

  test "identify garbage as an unknown script" do
    script = <<0>>

    script_type = Analyzer.identify(script)

    assert :unknown == script_type
  end
end
