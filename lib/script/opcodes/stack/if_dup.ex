defmodule BitcoinLib.Script.Opcodes.Stack.IfDup do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_IFDUP
  Opcode 115
  Hex 0x73
  Input x
  Output x / x x
  If the top stack value is not 0, duplicate it.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Stack.IfDup

  @value 0x73

  @doc """
  Returns 0x73

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.IfDup.v()
      0x73
  """
  @spec v() :: 0x73
  def v do
    @value
  end

  @doc """
  Returns <<0x73>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.IfDup.encode()
      <<0x73>>
  """
  def encode() do
    <<@value::8>>
  end

  @doc """
  If the top stack value is not 0, duplicate it.

  ## Examples
      iex> stack = [4, 3]
      ...> %BitcoinLib.Script.Opcodes.Stack.IfDup{}
      ...> |> BitcoinLib.Script.Opcodes.Stack.IfDup.execute(stack)
      {:ok, [4, 4, 3]}
  """
  @spec execute(%IfDup{}, list()) :: {:ok, list()} | {:error, binary()}
  def execute(_opcode, []), do: {:error, "trying to execute OP_DROP on an empty stack"}

  def execute(_opcode, [0 | _rest] = stack), do: {:ok, stack}

  def execute(_opcode, [first_element | rest]) do
    {:ok, [first_element | [first_element | rest]]}
  end
end
