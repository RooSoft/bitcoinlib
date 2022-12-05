defmodule BitcoinLib.Script.Opcodes.Constants.OneNegate do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_1NEGATE
  Opcode 79
  Hex 0x4f
  Input Nothing.
  Output -1
  Description The number -1 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.OneNegate

  @type t :: OneNegate

  @value 0x4F

  @doc """
  Returns 0x4f

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.OneNegate.v()
      0x4f
  """
  @spec v() :: 0x4F
  def v do
    @value
  end

  @doc """
  Returns <<0x4f>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.OneNegate.encode()
      <<0x4f>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 1 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.OneNegate.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.OneNegate{},
      ...>  [3]
      ...> )
      {:ok, [-1,3]}
  """
  @spec execute(OneNegate.t(), list()) :: {:ok, list()}
  def execute(%OneNegate{}, [remaining]) do
    {:ok, [-1, remaining]}
  end
end
