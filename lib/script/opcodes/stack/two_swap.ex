defmodule BitcoinLib.Script.Opcodes.Stack.TwoSwap do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_2SWAP
  Opcode 114
  Hex 0x72
  Input x1 x2 x3 x4
  Output x3 x4 x1 x2
  Swaps the top two pairs of items.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Stack.TwoSwap

  @value 0x72

  @doc """
  Returns 0x72

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.TwoSwap.v()
      0x72
  """
  @spec v() :: 0x72
  def v do
    @value
  end

  @doc """
  Returns <<0x72>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.TwoSwap.encode()
      <<0x72>>
  """
  def encode() do
    <<@value::8>>
  end

  @doc """
  Swaps the top two pairs of items.

  ## Examples
      iex> stack = [1, 2, 3, 4, 5]
      ...> %BitcoinLib.Script.Opcodes.Stack.TwoSwap{}
      ...> |> BitcoinLib.Script.Opcodes.Stack.TwoSwap.execute(stack)
      {:ok, [3, 4, 1, 2, 5]}
  """
  @spec execute(%TwoSwap{}, list()) :: {:ok, list()} | {:error, binary()}
  def execute(_opcode, []), do: {:error, "trying to execute OP_2OVER on an empty stack"}
  def execute(_opcode, [_]), do: {:error, "trying to execute OP_2OVER on a 1 element stack"}
  def execute(_opcode, [_, _]), do: {:error, "trying to execute OP_2OVER on a 2 elements stack"}
  def execute(_opcode, [_, _, _]), do: {:error, "trying to execute OP_2OVER on a 3 elements stack"}

  def execute(_opcode, [x1, x2, x3, x4] ++ rest) do
    {:ok, [x3, x4, x1, x2] ++ rest}
  end
end
