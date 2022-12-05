defmodule BitcoinLib.Script.Opcodes.Stack.Depth do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_DEPTH
  Opcode 116
  Hex 0x74
  Input nothing
  Output stack size
  Puts the number of stack items onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Stack.Depth

  @type t :: Depth

  @value 0x74

  @doc """
  Returns 0x74

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.Depth.v()
      0x74
  """
  @spec v() :: 0x74
  def v do
    @value
  end

  @doc """
  Returns <<0x74>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.Depth.encode()
      <<0x74>>
  """
  def encode() do
    <<@value::8>>
  end

  @doc """
  Swaps the top two pairs of items.

  ## Examples
      iex> stack = [1, 2, 3, 4, 5]
      ...> %BitcoinLib.Script.Opcodes.Stack.Depth{}
      ...> |> BitcoinLib.Script.Opcodes.Stack.Depth.execute(stack)
      {:ok, [5, 1, 2, 3, 4, 5]}
  """
  @spec execute(Depth.t(), list()) :: {:ok, list()} | {:error, binary()}

  def execute(_opcode, stack) do
    depth = Enum.count(stack)

    {:ok, [depth | stack]}
  end
end
