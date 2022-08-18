defmodule BitcoinLib.Script do
  alias BitcoinLib.Script.{Analyzer, Parser, Runner}

  @spec parse(bitstring()) :: list()
  def parse(script) when is_bitstring(script) do
    script
    |> Parser.parse()
  end

  @spec execute(bitstring(), list()) :: {:ok, boolean()} | {:error, binary()}
  def execute(script, stack) when is_bitstring(script) do
    script
    |> Runner.execute(stack)
  end

  @spec identify(bitstring()) :: :unknown | :p2pk | :p2pkh | :p2sh
  def identify(script) when is_bitstring(script) do
    script
    |> Analyzer.identify()
  end
end
