defmodule BitcoinLib.Script.Opcodes.Constants.Ten do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_10
  Opcode 90
  Hex 0x5a
  Input Nothing
  Output 10
  The number 10 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Ten

  @value 0x5A

  @doc """
  Returns 0x5a

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Ten.v()
      0x5a
  """
  @spec v() :: 0x5A
  def v do
    @value
  end

  @doc """
  Returns <<0x5a>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Ten.encode()
      <<0x5a>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 10 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Ten.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Ten{},
      ...>  [3]
      ...> )
      {:ok, [10, 3]}
  """
  def execute(%Ten{}, remaining) do
    {:ok, [10 | remaining]}
  end
end
