defmodule BitcoinLib.Script.Opcodes.FlowControl.Nop do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_NOP
  Opcode 97
  Hex 0x61
  Input Nothing
  Output fail
  Description
    Does nothing.

  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.FlowControl.Nop

  @value 0x61

  @doc """
  Returns 0x61

  ## Examples
      iex> BitcoinLib.Script.Opcodes.FlowControl.Nop.v()
      0x61
  """
  @spec v() :: 0x61
  def v do
    @value
  end

  @doc """
  Returns <<0x61>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.FlowControl.Nop.encode()
      <<0x61>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  Pushes nothing onto the stack

  ## Examples
      iex> stack = [3]
      ...> %BitcoinLib.Script.Opcodes.FlowControl.Nop{}
      ...> |> BitcoinLib.Script.Opcodes.FlowControl.Nop.execute(stack)
      {:ok, [3]}
  """
  @spec execute(%Nop{}, list()) :: {:ok, list()}
  def execute(%Nop{}, stack) do
    {:ok, stack}
  end
end
