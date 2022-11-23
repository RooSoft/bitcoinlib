defmodule BitcoinLib.Script.Opcodes.Stack.TwoOver do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_2OVER
  Opcode 112
  Hex 0x70
  Input x1 x2 x3 x4
  Output x1 x2 x3 x4 x1 x2
  Copies the pair of items two spaces back in the stack to the front.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Stack.TwoOver

  @value 0x70

  @doc """
  Returns 0x70

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.TwoOver.v()
      0x70
  """
  @spec v() :: 0x70
  def v do
    @value
  end

  @doc """
  Returns <<0x70>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.TwoOver.encode()
      <<0x70>>
  """
  def encode() do
    <<@value::8>>
  end

  @doc """
  Copies the pair of items two spaces back in the stack to the front.

  ## Examples
      iex> stack = [1, 2, 3, 4, 5]
      ...> %BitcoinLib.Script.Opcodes.Stack.TwoOver{}
      ...> |> BitcoinLib.Script.Opcodes.Stack.TwoOver.execute(stack)
      {:ok, [1, 2, 3, 4, 1, 2, 5]}
  """
  @spec execute(%TwoOver{}, list()) :: {:ok, list()} | {:error, binary()}
  def execute(_opcode, []), do: {:error, "trying to execute OP_2OVER on an empty stack"}
  def execute(_opcode, [_]), do: {:error, "trying to execute OP_2OVER on a 1 element stack"}
  def execute(_opcode, [_, _]), do: {:error, "trying to execute OP_2OVER on a 2 elements stack"}
  def execute(_opcode, [_, _, _]), do: {:error, "trying to execute OP_2OVER on a 3 elements stack"}

  def execute(_opcode, [x1, x2, x3, x4] ++ rest) do
    {:ok, [x1, x2, x3, x4, x1, x2] ++ rest}
  end
end
