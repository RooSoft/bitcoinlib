defmodule BitcoinLib.Script.Opcodes.Reserved.Nop1 do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_NOP1
  Opcode 176
  Hex 0xb0
  Input nothing
  Output nothing
  The word is ignored. Does not mark transaction as invalid.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Reserved.Nop1

  @type t :: Nop1

  @value 0xB0

  @doc """
  Returns 0xb0

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Reserved.Nop1.v()
      0xb0
  """
  @spec v() :: 0xB0
  def v do
    @value
  end

  @doc """
  Returns <<0xb0>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Reserved.Nop1.encode()
      <<0xb0>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 1 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Reserved.Nop1.execute(
      ...>  %BitcoinLib.Script.Opcodes.Reserved.Nop1{},
      ...>  [3]
      ...> )
      {:ok, [3]}
  """
  @spec execute(Nop1.t(), list()) :: {:ok, list()}
  def execute(%Nop1{}, remaining) do
    {:ok, remaining}
  end
end
