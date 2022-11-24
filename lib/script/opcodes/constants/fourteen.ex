defmodule BitcoinLib.Script.Opcodes.Constants.Fourteen do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_14
  Opcode 94
  Hex 0x5e
  Input Nothing
  Output 14
  The number 14 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Fourteen

  @value 0x5E

  @doc """
  Returns 0x5e

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Fourteen.v()
      0x5e
  """
  @spec v() :: 0x5E
  def v do
    @value
  end

  @doc """
  Returns <<0x5e>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Fourteen.encode()
      <<0x5e>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 14 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Fourteen.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Fourteen{},
      ...>  [3]
      ...> )
      {:ok, [14, 3]}
  """
  def execute(%Fourteen{}, remaining) do
    {:ok, [14 | remaining]}
  end
end
