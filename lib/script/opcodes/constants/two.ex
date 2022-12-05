defmodule BitcoinLib.Script.Opcodes.Constants.Two do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_2
  Opcode 82
  Hex 0x52
  Input Nothing.
  Output 2
  Description The number 2 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Two

  @type t :: Two

  @value 0x52

  @doc """
  Returns 0x52

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Two.v()
      0x52
  """
  def v do
    @value
  end

  @doc """
  Returns <<0x52>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Two.encode()
      <<0x52>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 2 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Two.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Two{},
      ...>  [3]
      ...> )
      {:ok, [2,3]}
  """
  @spec execute(Two.t(), list()) :: {:ok, list()}
  def execute(%Two{}, [remaining]) do
    {:ok, [2, remaining]}
  end
end
