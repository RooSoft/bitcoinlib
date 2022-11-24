defmodule BitcoinLib.Script.Opcodes.Constants.Fifteen do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_15
  Opcode 95
  Hex 0x5f
  Input Nothing
  Output 15
  The number 15 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Fifteen

  @value 0x5F

  @doc """
  Returns 0x5f

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Fifteen.v()
      0x5f
  """
  @spec v() :: 0x5F
  def v do
    @value
  end

  @doc """
  Returns <<0x5f>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Fifteen.encode()
      <<0x5f>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 15 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Fifteen.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Fifteen{},
      ...>  [3]
      ...> )
      {:ok, [15, 3]}
  """
  def execute(%Fifteen{}, remaining) do
    {:ok, [15 | remaining]}
  end
end
