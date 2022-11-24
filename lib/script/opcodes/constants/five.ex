defmodule BitcoinLib.Script.Opcodes.Constants.Five do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_5
  Opcode 85
  Hex 0x55
  Input Nothing
  Output 4
  The number 4 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Five

  @value 0x55

  @doc """
  Returns 0x55

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Five.v()
      0x55
  """
  @spec v() :: 0x55
  def v do
    @value
  end

  @doc """
  Returns <<0x55>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Five.encode()
      <<0x55>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 4 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Five.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Five{},
      ...>  [3]
      ...> )
      {:ok, [5, 3]}
  """
  def execute(%Five{}, remaining) do
    {:ok, [5 | remaining]}
  end
end
