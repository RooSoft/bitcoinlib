defmodule BitcoinLib.Script.Opcodes.Stack.FromAltStack do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_FROMALTSTACK
  Opcode 108
  Hex 0x6c
  Input (alt)x1
  Output x1
  Puts the input onto the top of the main stack. Removes it from the alt stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  @value 0x6C

  @doc """
  Returns 0x6c

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.FromAltStack.v()
      0x6c
  """
  @spec v() :: 0x6C
  def v do
    @value
  end

  @doc """
  Returns <<0x6c>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.FromAltStack.encode()
      <<0x6c>>
  """
  def encode() do
    <<@value::8>>
  end

  def execute(_opcode, [_first_element | _remaining]) do
    {:error, "OP_FROMALTSTACK execution has not been implemented yet"}
  end
end
