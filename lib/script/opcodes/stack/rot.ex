defmodule BitcoinLib.Script.Opcodes.Stack.Rot do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_ROT
  Opcode 123
  Hex 0x7b
  Input x1 x2 x3
  Output x2 x3 x1
  The 3rd item down the stack is moved to the top.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Stack.Rot

  @value 0x7B

  @doc """
  Returns 0x7b

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.Rot.v()
      0x7b
  """
  @spec v() :: 0x7B
  def v do
    @value
  end

  @doc """
  Returns <<0x7b>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.Rot.encode()
      <<0x7b>>
  """
  def encode() do
    <<@value::8>>
  end

  @doc """
  The 3rd item down the stack is moved to the top.

  ## Examples
      iex> stack = [4, 3, 6, 1, 2]
      ...> %BitcoinLib.Script.Opcodes.Stack.Rot{}
      ...> |> BitcoinLib.Script.Opcodes.Stack.Rot.execute(stack)
      {:ok, [6, 4, 3, 1, 2]}
  """
  @spec execute(%Rot{}, list()) :: {:ok, list()} | {:error, binary()}
  def execute(_opcode, []), do: {:error, "trying to execute OP_ROT on an empty stack"}
  def execute(_opcode, [_]), do: {:error, "trying to execute OP_ROT on a one element stack"}
  def execute(_opcode, [_, _]), do: {:error, "trying to execute OP_ROT on a two element stack"}

  def execute(_opcode, [x1 | [x2 | [x3 | remaining]]]) do
    {:ok, [x3 | [x1 | [x2 | remaining]]]}
  end
end
