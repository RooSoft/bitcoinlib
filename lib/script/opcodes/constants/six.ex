defmodule BitcoinLib.Script.Opcodes.Constants.Six do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_6
  Opcode 86
  Hex 0x56
  Input Nothing
  Output 6
  The number 6 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Six

  @value 0x56

  @doc """
  Returns 0x56

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Six.v()
      0x56
  """
  @spec v() :: 0x56
  def v do
    @value
  end

  @doc """
  Returns <<0x56>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Six.encode()
      <<0x56>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 6 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Six.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Six{},
      ...>  [3]
      ...> )
      {:ok, [6, 3]}
  """
  def execute(%Six{}, remaining) do
    {:ok, [6 | remaining]}
  end
end
