defmodule BitcoinLib.Script.Opcodes.Constants.Nine do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_9
  Opcode 89
  Hex 0x59
  Input Nothing
  Output 9
  The number 9 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Nine

  @value 0x59

  @doc """
  Returns 0x59

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Nine.v()
      0x59
  """
  @spec v() :: 0x59
  def v do
    @value
  end

  @doc """
  Returns <<0x59>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Nine.encode()
      <<0x59>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 9 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Nine.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Nine{},
      ...>  [3]
      ...> )
      {:ok, [9, 3]}
  """
  def execute(%Nine{}, remaining) do
    {:ok, [9 | remaining]}
  end
end
