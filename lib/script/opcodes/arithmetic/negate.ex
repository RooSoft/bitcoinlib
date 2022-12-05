defmodule BitcoinLib.Script.Opcodes.Arithmetic.Negate do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_NEGATE
  Opcode 143
  Hex 0x8f
  Input in
  Output out
  The sign of the input is flipped.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Arithmetic.Negate

  @type t :: Negate

  @value 0x8F

  @doc """
  Returns 0x8f

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Negate.v()
      0x8f
  """
  @spec v() :: 0x8F
  def v do
    @value
  end

  @doc """
  Returns <<0x8f>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Negate.encode()
      <<0x8f>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The sign of the input is flipped.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Negate.execute(
      ...>  %BitcoinLib.Script.Opcodes.Arithmetic.Negate{},
      ...>  [2, 3, 1]
      ...> )
      {:ok, [-2, 3, 1]}
  """
  @spec execute(Negate.t(), list()) :: {:ok, list()}
  def execute(%Negate{}, [first] ++ remaining) do
    {:ok, [-first | remaining]}
  end
end
