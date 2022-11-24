defmodule BitcoinLib.Script.Opcodes.Constants.Seven do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_7
  Opcode 87
  Hex 0x57
  Input Nothing
  Output 7
  The number 7 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Seven

  @value 0x57

  @doc """
  Returns 0x57

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Seven.v()
      0x57
  """
  @spec v() :: 0x57
  def v do
    @value
  end

  @doc """
  Returns <<0x57>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Seven.encode()
      <<0x57>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 7 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Seven.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Seven{},
      ...>  [3]
      ...> )
      {:ok, [7, 3]}
  """
  def execute(%Seven{}, remaining) do
    {:ok, [7 | remaining]}
  end
end
