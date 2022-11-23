defmodule BitcoinLib.Script.Opcodes.Constants.Four do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_4
  Opcode 84
  Hex 0x54
  Input Nothing
  Output 4
  The number 4 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Four

  @value 0x54

  @doc """
  Returns 0x54

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Four.v()
      0x54
  """
  @spec v() :: 0x54
  def v do
    @value
  end

  @doc """
  Returns <<0x54>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Four.encode()
      <<0x54>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 4 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Four.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Four{},
      ...>  [3]
      ...> )
      {:ok, [4, 3]}
  """
  def execute(%Four{}, remaining) do
    {:ok, [4 | remaining]}
  end
end
