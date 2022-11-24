defmodule BitcoinLib.Script.Opcodes.Constants.Eleven do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_11
  Opcode 91
  Hex 0x5b
  Input Nothing
  Output 11
  The number 11 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Eleven

  @value 0x5B

  @doc """
  Returns 0x5b

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Eleven.v()
      0x5b
  """
  @spec v() :: 0x5B
  def v do
    @value
  end

  @doc """
  Returns <<0x5b>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Eleven.encode()
      <<0x5b>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 11 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Eleven.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Eleven{},
      ...>  [3]
      ...> )
      {:ok, [11, 3]}
  """
  def execute(%Eleven{}, remaining) do
    {:ok, [11 | remaining]}
  end
end
