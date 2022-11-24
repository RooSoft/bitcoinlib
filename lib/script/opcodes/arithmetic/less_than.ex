defmodule BitcoinLib.Script.Opcodes.Arithmetic.LessThan do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_LESSTHAN
  Opcode 159
  Hex 0x9f
  Input in
  Output out
  Returns 1 if a is less than b, 0 otherwise.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Arithmetic.LessThan

  @value 0x9F

  @doc """
  Returns 0x9f

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.LessThan.v()
      0x9f
  """
  @spec v() :: 0x9F
  def v do
    @value
  end

  @doc """
  Returns <<0x9f>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.LessThan.encode()
      <<0x9f>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  Returns 1 if a is less than b, 0 otherwise.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.LessThan.execute(
      ...>  %BitcoinLib.Script.Opcodes.Arithmetic.LessThan{},
      ...>  [2, 3, 4]
      ...> )
      {:ok, [1, 4]}
  """
  @spec execute(%LessThan{}, list()) :: {:ok, list()}
  def execute(%LessThan{}, [first, second] ++ remaining) do
    case first < second do
      true -> {:ok, [1 | remaining]}
      false -> {:ok, [0 | remaining]}
    end
  end
end
