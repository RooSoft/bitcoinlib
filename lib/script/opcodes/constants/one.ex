defmodule BitcoinLib.Script.Opcodes.Constants.One do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_1, OP_TRUE
  Opcode 81
  Hex 0x51
  Input Nothing.
  Output 1
  Description The number 1 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.One

  @value 0x51

  @doc """
  Returns 0x51

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.One.v()
      0x51
  """
  @spec v() :: 0x51
  def v do
    @value
  end

  @doc """
  Returns <<0x51>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.One.encode()
      <<0x51>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 1 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.One.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.One{},
      ...>  [3]
      ...> )
      {:ok, [1,3]}
  """
  @spec execute(%One{}, list()) :: {:ok, list()}
  def execute(%One{}, [remaining]) do
    {:ok, [1, remaining]}
  end
end
