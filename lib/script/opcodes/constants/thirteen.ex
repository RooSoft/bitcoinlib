defmodule BitcoinLib.Script.Opcodes.Constants.Thirteen do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_13
  Opcode 93
  Hex 0x5d
  Input Nothing
  Output 13
  The number 13 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Thirteen

  @value 0x5D

  @doc """
  Returns 0x5d

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Thirteen.v()
      0x5d
  """
  @spec v() :: 0x5D
  def v do
    @value
  end

  @doc """
  Returns <<0x5d>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Thirteen.encode()
      <<0x5d>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 13 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Thirteen.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Thirteen{},
      ...>  [3]
      ...> )
      {:ok, [13, 3]}
  """
  def execute(%Thirteen{}, remaining) do
    {:ok, [13 | remaining]}
  end
end
