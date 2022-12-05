defmodule BitcoinLib.Script.Opcodes.Arithmetic.Not do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_NOT
  Opcode 145
  Hex 0x91
  Input in
  Output out
  If the input is 0 or 1, it is flipped. Otherwise the output will be 0.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Arithmetic.Not

  @type t :: Not

  @value 0x91

  @doc """
  Returns 0x91

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Not.v()
      0x91
  """
  @spec v() :: 0x91
  def v do
    @value
  end

  @doc """
  Returns <<0x91>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Not.encode()
      <<0x91>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  If the input is 0 or 1, it is flipped. Otherwise the output will be 0.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Not.execute(
      ...>  %BitcoinLib.Script.Opcodes.Arithmetic.Not{},
      ...>  [1, 3, 1]
      ...> )
      {:ok, [0, 3, 1]}
  """
  @spec execute(Not.t(), list()) :: {:ok, list()}
  def execute(%Not{}, [0] ++ remaining) do
    {:ok, [1 | remaining]}
  end

  def execute(%Not{}, [_] ++ remaining) do
    {:ok, [0 | remaining]}
  end
end
