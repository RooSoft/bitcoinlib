defmodule BitcoinLib.Script.Opcodes.Stack.TwoDup do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_2DUP
  Opcode 110
  Hex 0x6e
  Input x1 x2
  Output x1 x2 x1 x2
  Duplicates the top two stack items.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Stack.TwoDup

  @type t :: TwoDup

  @value 0x6E

  @doc """
  Returns 0x6e

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.TwoDup.v()
      0x6e
  """
  @spec v() :: 0x6E
  def v do
    @value
  end

  @doc """
  Returns <<0x6e>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.TwoDup.encode()
      <<0x6e>>
  """
  def encode() do
    <<@value::8>>
  end

  @doc """
  Duplicates the top stack item.

  ## Examples
      iex> stack = [4, 3, 5]
      ...> %BitcoinLib.Script.Opcodes.Stack.TwoDup{}
      ...> |> BitcoinLib.Script.Opcodes.Stack.TwoDup.execute(stack)
      {:ok, [4, 3, 4, 3, 5]}
  """
  @spec execute(TwoDup.t(), list()) :: {:ok, list()} | {:error, binary()}
  def execute(_opcode, []), do: {:error, "trying to execute OP_2DUP on an empty stack"}
  def execute(_opcode, [_]), do: {:error, "trying to execute OP_2DUP on a one element stack"}

  def execute(_opcode, [first, second] ++ remaining) do
    {:ok, [first, second, first, second] ++ remaining}
  end
end
