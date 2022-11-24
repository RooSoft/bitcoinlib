defmodule BitcoinLib.Script.Opcodes.Arithmetic.Abs do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_ABS
  Opcode 144
  Hex 0x90
  Input in
  Output out
  The input is made positive.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Arithmetic.Abs

  @value 0x90

  @doc """
  Returns 0x90

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Abs.v()
      0x90
  """
  @spec v() :: 0x90
  def v do
    @value
  end

  @doc """
  Returns <<0x90>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Abs.encode()
      <<0x90>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The input is made positive.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Abs.execute(
      ...>  %BitcoinLib.Script.Opcodes.Arithmetic.Abs{},
      ...>  [-2, 3, 1]
      ...> )
      {:ok, [2, 3, 1]}
  """
  @spec execute(%Abs{}, list()) :: {:ok, list()}
  def execute(%Abs{}, [first] ++ remaining) do
    {:ok, [abs(first) | remaining]}
  end
end
