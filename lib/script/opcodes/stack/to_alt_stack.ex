defmodule BitcoinLib.Script.Opcodes.Stack.ToAltStack do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_TOALTSTACK
  Opcode 107
  Hex 0x6b
  Input nothing
  Output stack size
  Puts the input onto the top of the alt stack. Removes it from the main stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  @value 0x6B

  @doc """
  Returns 0x6b

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.ToAltStack.v()
      0x6b
  """
  @spec v() :: 0x6B
  def v do
    @value
  end

  @doc """
  Returns <<0x6b>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Stack.ToAltStack.encode()
      <<0x6b>>
  """
  def encode() do
    <<@value::8>>
  end

  def execute(_opcode, [_first_element | _remaining]) do
    {:error, "OP_TOALTSTACK execution has not been implemented yet"}
  end
end
