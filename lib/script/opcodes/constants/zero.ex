defmodule BitcoinLib.Script.Opcodes.Constants.Zero do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_0, OP_FALSE
  Opcode 0
  Hex 0x00
  Input Nothing.
  Output (empty value)
  Description An empty array of bytes is pushed onto the stack. (This is not a no-op: an item is added to the stack.)
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Zero

  @value 0x00

  @doc """
  Returns 0

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Zero.v()
      0
  """
  @spec v() :: 0
  def v do
    @value
  end

  @doc """
  Returns <<0>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Zero.encode()
      <<0>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  An empty array of bytes is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Zero.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Zero{},
      ...>  [3]
      ...> )
      {:ok, [nil ,3]}
  """
  def execute(%Zero{}, [remaining]) do
    {:ok, [nil, remaining]}
  end
end
