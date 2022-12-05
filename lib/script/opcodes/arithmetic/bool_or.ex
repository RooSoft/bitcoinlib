defmodule BitcoinLib.Script.Opcodes.Arithmetic.BoolOr do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_BOOLOR
  Opcode 155
  Hex 0x9b
  Input a b
  Output out
  If a or b is not 0, the output is 1. Otherwise 0.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Arithmetic.BoolOr

  @type t :: BoolOr

  @value 0x9B

  @doc """
  Returns 0x9b

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.BoolOr.v()
      0x9b
  """
  @spec v() :: 0x9B
  def v do
    @value
  end

  @doc """
  Returns <<0x9b>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.BoolOr.encode()
      <<0x9b>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  If a or b is not 0, the output is 1. Otherwise 0.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.BoolOr.execute(
      ...>  %BitcoinLib.Script.Opcodes.Arithmetic.BoolOr{},
      ...>  [0, 3, 1]
      ...> )
      {:ok, [1, 1]}
  """
  @spec execute(BoolOr.t(), list()) :: {:ok, list()}
  def execute(%BoolOr{}, [first, second] ++ remaining) do
    or_result =
      case first != 0 || second != 0 do
        true -> 1
        false -> 0
      end

    {:ok, [or_result | remaining]}
  end
end
