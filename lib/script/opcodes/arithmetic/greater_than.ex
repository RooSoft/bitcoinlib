defmodule BitcoinLib.Script.Opcodes.Arithmetic.GreaterThan do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_GREATERTHAN
  Opcode 160
  Hex 0xa0
  Input a b
  Output out
  Returns 1 if a is greater than b, 0 otherwise.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Arithmetic.GreaterThan

  @type t :: GreaterThan

  @value 0xA0

  @doc """
  Returns 0xa0

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.GreaterThan.v()
      0xa0
  """
  @spec v() :: 0xA0
  def v do
    @value
  end

  @doc """
  Returns <<0xa0>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.GreaterThan.encode()
      <<0xa0>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  Returns 1 if a is greater than b, 0 otherwise.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.GreaterThan.execute(
      ...>  %BitcoinLib.Script.Opcodes.Arithmetic.GreaterThan{},
      ...>  [2, 3, 1]
      ...> )
      {:ok, [0, 1]}
  """
  @spec execute(GreaterThan.t(), list()) :: {:ok, list()}
  def execute(%GreaterThan{}, [first, second] ++ remaining) do
    case first > second do
      true -> {:ok, [1 | remaining]}
      false -> {:ok, [0 | remaining]}
    end
  end
end
