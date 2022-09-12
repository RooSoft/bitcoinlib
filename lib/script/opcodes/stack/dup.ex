defmodule BitcoinLib.Script.Opcodes.Stack.Dup do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_DUP
  Opcode 118
  Hex 0x76
  Input x
  Output x x
  Description Duplicates the top stack item.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Stack.Dup

  @value 0x76

  @doc """
  Returns 0x76

  ## Examples
    iex> BitcoinLib.Script.Opcodes.Stack.Dup.v()
    0x76
  """
  @spec v() :: 0x76
  def v do
    @value
  end

  @doc """
  Returns <<0x76>>

  ## Examples
    iex> BitcoinLib.Script.Opcodes.Stack.Dup.encode()
    <<0x76>>
  """
  def encode() do
    <<@value::8>>
  end

  @doc """
  Duplicates the top stack item.

  ## Examples
    iex> stack = [4, 3]
    ...> %BitcoinLib.Script.Opcodes.Stack.Dup{}
    ...> |> BitcoinLib.Script.Opcodes.Stack.Dup.execute(stack)
    {:ok, [4, 4, 3]}
  """
  @spec execute(%Dup{}, list()) :: {:ok, list()} | {:error, binary()}
  def execute(_opcode, []), do: {:error, "trying to execute OP_DUP on an empty stack"}

  def execute(_opcode, [first_element | _] = stack) do
    {:ok, [first_element | stack]}
  end
end
