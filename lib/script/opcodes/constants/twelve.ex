defmodule BitcoinLib.Script.Opcodes.Constants.Twelve do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_12
  Opcode 92
  Hex 0x5c
  Input Nothing
  Output 12
  The number 12 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Twelve

  @value 0x5C

  @doc """
  Returns 0x5c

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Twelve.v()
      0x5c
  """
  @spec v() :: 0x5C
  def v do
    @value
  end

  @doc """
  Returns <<0x5c>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Twelve.encode()
      <<0x5c>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 12 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Twelve.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Twelve{},
      ...>  [3]
      ...> )
      {:ok, [12, 3]}
  """
  def execute(%Twelve{}, remaining) do
    {:ok, [12 | remaining]}
  end
end
