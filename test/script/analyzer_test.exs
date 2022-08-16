defmodule BitcoinLib.Script.AnalyzerTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Script.Analyzer

  test "identify a P2PKH script" do
    script = <<0x76A914725EBAC06343111227573D0B5287954EF9B88AAE88AC::200>>

    script_type = Analyzer.identify(script)

    assert :p2pkh == script_type
  end
end
