defmodule BitcoinLib.Script.Opcodes.Stack.Swap do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_SWAP
  Opcode 124
  Hex 0x7c
  Input x1 x2
  Output x2 x1
  The top two items on the stack are swapped.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Stack.Swap

  @value 0x7C

  @doc """
  Returns 0x7c

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.Swap.v()
      0x7c
  """
  @spec v() :: 0x7C
  def v do
    @value
  end

  @doc """
  Returns <<0x7c>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.Swap.encode()
      <<0x7c>>
  """
  def encode() do
    <<@value::8>>
  end

  @doc """
  The top two items on the stack are swapped.

  ## Examples
      iex> stack = [1, 2, 3, 4, 5]
      ...> %BitcoinLib.Script.Opcodes.Stack.Swap{}
      ...> |> BitcoinLib.Script.Opcodes.Stack.Swap.execute(stack)
      {:ok, [2, 1, 3, 4, 5]}
  """
  @spec execute(%Swap{}, list()) :: {:ok, list()} | {:error, binary()}
  def execute(_opcode, []), do: {:error, "trying to execute OP_SWAP on an empty stack"}
  def execute(_opcode, [_]), do: {:error, "trying to execute OP_SWAP on a 1 element stack"}

  def execute(_opcode, [x1, x2] ++ rest) do
    {:ok, [x2, x1] ++ rest}
  end
end
