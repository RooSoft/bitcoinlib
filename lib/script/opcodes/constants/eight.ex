defmodule BitcoinLib.Script.Opcodes.Constants.Eight do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_8
  Opcode 88
  Hex 0x58
  Input Nothing
  Output 8
  The number 8 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Eight

  @value 0x58

  @doc """
  Returns 0x58

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Eight.v()
      0x58
  """
  @spec v() :: 0x58
  def v do
    @value
  end

  @doc """
  Returns <<0x58>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Eight.encode()
      <<0x58>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 8 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Eight.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Eight{},
      ...>  [3]
      ...> )
      {:ok, [8, 3]}
  """
  def execute(%Eight{}, remaining) do
    {:ok, [8 | remaining]}
  end
end
