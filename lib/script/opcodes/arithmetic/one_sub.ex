defmodule BitcoinLib.Script.Opcodes.Arithmetic.OneSub do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_1SUB
  Opcode 140
  Hex 0x8c
  Input in
  Output out
  1 is subtracted from the input.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Arithmetic.OneSub

  @value 0x8C

  @doc """
  Returns 0x8c

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.OneSub.v()
      0x8c
  """
  @spec v() :: 0x8C
  def v do
    @value
  end

  @doc """
  Returns <<0x8c>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.OneSub.encode()
      <<0x8c>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  b is subtracted from a.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.OneSub.execute(
      ...>  %BitcoinLib.Script.Opcodes.Arithmetic.OneSub{},
      ...>  [7, 3, 1]
      ...> )
      {:ok, [6, 3, 1]}
  """
  @spec execute(%OneSub{}, list()) :: {:ok, list()}
  def execute(%OneSub{}, [first] ++ remaining) do
    {:ok, [first - 1 | remaining]}
  end
end
