defmodule BitcoinLib.Script.Opcodes.Stack.Drop do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_DROP
  Opcode 117
  Hex 0x75
  Input x
  Output nothing
  Removes the top stack item.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Stack.Drop

  @type t :: Drop

  @value 0x75

  @doc """
  Returns 0x75

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.Drop.v()
      0x75
  """
  @spec v() :: 0x75
  def v do
    @value
  end

  @doc """
  Returns <<0x75>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.Drop.encode()
      <<0x75>>
  """
  def encode() do
    <<@value::8>>
  end

  @doc """
  Removes the top stack item.

  ## Examples
      iex> stack = [4, 3]
      ...> %BitcoinLib.Script.Opcodes.Stack.Drop{}
      ...> |> BitcoinLib.Script.Opcodes.Stack.Drop.execute(stack)
      {:ok, [3]}
  """
  @spec execute(Drop.t(), list()) :: {:ok, list()} | {:error, binary()}
  def execute(_opcode, []), do: {:error, "trying to execute OP_DROP on an empty stack"}

  def execute(_opcode, [_first_element | rest]) do
    {:ok, rest}
  end
end
