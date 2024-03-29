defmodule BitcoinLib.Script do
  @moduledoc """
  Script manipulation module
  """

  alias BitcoinLib.Script.{Analyzer, Encoder, Parser, Runner}
  alias BitcoinLib.Signing.Psbt.CompactInteger

  @doc """
  Transforms a script in the bitstring form into a list of opcodes

  ## Examples
      iex> <<0x76a914fde0a08625e327ba400644ad62d5c571d2eec3de88ac::200>>
      ...> |> BitcoinLib.Script.parse()
      {
        :ok,
        [
          %BitcoinLib.Script.Opcodes.Stack.Dup{},
          %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
          %BitcoinLib.Script.Opcodes.Data{
            value: <<0xfde0a08625e327ba400644ad62d5c571d2eec3de::160>>
          },
          %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
          %BitcoinLib.Script.Opcodes.Crypto.CheckSig{
            script: <<0x76a914fde0a08625e327ba400644ad62d5c571d2eec3de88ac::200>>
          }
        ]
      }
  """
  @spec parse(bitstring()) :: {:ok, list()} | {:error, binary()}
  def parse(script) when is_bitstring(script) do
    script
    |> Parser.parse()
  end

  @doc """
  Transforms a script in the bitstring form into a list of opcodes

  ## Examples
      iex> <<0x76a914fde0a08625e327ba400644ad62d5c571d2eec3de88ac::200>>
      ...> |> BitcoinLib.Script.parse!()
      [
        %BitcoinLib.Script.Opcodes.Stack.Dup{},
        %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
        %BitcoinLib.Script.Opcodes.Data{
          value: <<0xfde0a08625e327ba400644ad62d5c571d2eec3de::160>>
        },
        %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
        %BitcoinLib.Script.Opcodes.Crypto.CheckSig{
          script: <<0x76a914fde0a08625e327ba400644ad62d5c571d2eec3de88ac::200>>
        }
      ]
  """
  @spec parse!(bitstring()) :: list()
  def parse!(script) when is_bitstring(script) do
    parse(script)
    |> elem(1)
  end

  @doc """
  Transforms a list of opcodes into a compact integer reprensenting the size of the script,
  and the script itself

  ## Examples
      iex> [
      ...>   %BitcoinLib.Script.Opcodes.Stack.Dup{},
      ...>   %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
      ...>   %BitcoinLib.Script.Opcodes.Data{
      ...>     value: <<0xfde0a08625e327ba400644ad62d5c571d2eec3de::160>>
      ...>   },
      ...>   %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
      ...>   %BitcoinLib.Script.Opcodes.Crypto.CheckSig{}
      ...> ] |> BitcoinLib.Script.encode
      {<<0x19>>, <<0x76a914fde0a08625e327ba400644ad62d5c571d2eec3de88ac::200>>}
  """
  @spec encode(list()) :: {bitstring(), bitstring()}
  def encode(script) when is_list(script) do
    encoded_script =
      script
      |> Encoder.to_bitstring()

    encoded_script_size =
      byte_size(encoded_script)
      |> CompactInteger.encode()

    {encoded_script_size, encoded_script}
  end

  @spec execute(bitstring(), list()) :: {:ok, boolean()} | {:error, binary()}
  def execute(script, stack) when is_bitstring(script) do
    case Parser.parse(script) do
      {:ok, parsed_script} -> execute(parsed_script, stack)
      {:error, message} -> {:error, message}
    end
  end

  @spec execute(list(), list()) :: {:ok, boolean()} | {:error, binary()}
  def execute(script, stack) when is_list(script) do
    script
    |> Runner.execute(stack)
  end

  @spec validate(bitstring(), list()) :: {:ok, boolean()} | {:error, binary()}
  def validate(script, stack) when is_bitstring(script) do
    case Parser.parse(script) do
      {:ok, parsed_script} -> validate(parsed_script, stack)
      {:error, message} -> {:error, message}
    end
  end

  @spec validate(list(), list()) :: {:ok, boolean()} | {:error, binary()}
  def validate(script, stack) when is_list(script) do
    script
    |> Runner.validate(stack)
  end

  @spec identify(bitstring() | list()) ::
          {:unknown} | {:p2pk | :p2pkh | :p2sh | :p2wsh | :p2wpkh, bitstring()}
  def identify(script) do
    script
    |> Analyzer.identify()
  end
end
