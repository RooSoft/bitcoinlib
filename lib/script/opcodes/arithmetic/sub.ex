defmodule BitcoinLib.Script.Opcodes.Arithmetic.Sub do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_SUB
  Opcode 148
  Hex 0x94
  Input a b
  Output out
  b is subtracted from a.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Arithmetic.Sub

  @value 0x94

  @doc """
  Returns 0x94

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Sub.v()
      0x94
  """
  @spec v() :: 0x94
  def v do
    @value
  end

  @doc """
  Returns <<0x94>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Sub.encode()
      <<0x94>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The input is made positive.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Sub.execute(
      ...>  %BitcoinLib.Script.Opcodes.Arithmetic.Sub{},
      ...>  [7, 3, 1]
      ...> )
      {:ok, [4, 1]}
  """
  @spec execute(%Sub{}, list()) :: {:ok, list()}
  def execute(%Sub{}, [first, second] ++ remaining) do
    {:ok, [first - second | remaining]}
  end
end
