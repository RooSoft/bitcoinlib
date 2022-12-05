defmodule BitcoinLib.Script.Opcodes.Arithmetic.Within do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_WITHIN
  Opcode 165
  Hex 0xa5
  Input x min max
  Output out
  Returns 1 if x is within the specified range (left-inclusive), 0 otherwise.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Arithmetic.Within

  @type t :: Within

  @value 0xA5

  @doc """
  Returns 0xa5

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Within.v()
      0xa5
  """
  @spec v() :: 0xA5
  def v do
    @value
  end

  @doc """
  Returns <<0xa5>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Within.encode()
      <<0xa5>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  Returns 1 if x is within the specified range (left-inclusive), 0 otherwise.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Within.execute(
      ...>  %BitcoinLib.Script.Opcodes.Arithmetic.Within{},
      ...>  [5, 3, 6, 7]
      ...> )
      {:ok, [1, 7]}
  """
  @spec execute(Within.t(), list()) :: {:ok, list()}
  def execute(%Within{}, [first, second, third] ++ remaining) do
    case first >= second && first < third do
      true -> {:ok, [1 | remaining]}
      false -> {:ok, [0 | remaining]}
    end
  end
end
