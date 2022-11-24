defmodule BitcoinLib.Script.Opcodes.Constants.Sixteen do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_16
  Opcode 96
  Hex 0x60
  Input Nothing
  Output 16
  The number 16 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Sixteen

  @value 0x60

  @doc """
  Returns 0x60

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Sixteen.v()
      0x60
  """
  @spec v() :: 0x60
  def v do
    @value
  end

  @doc """
  Returns <<0x60>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Sixteen.encode()
      <<0x60>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 16 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Sixteen.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Sixteen{},
      ...>  [3]
      ...> )
      {:ok, [16, 3]}
  """
  def execute(%Sixteen{}, remaining) do
    {:ok, [16 | remaining]}
  end
end
