defmodule BitcoinLib.Script.Opcodes.BitwiseLogic.Equal do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script#Bitwise_logic

  Word OP_EQUAL
  Opcode 135
  Hex 0x87
  Input x1 x2
  Output True / false
  Description Returns 1 if the inputs are exactly equal, 0 otherwise
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  @value 0x87

  def v do
    @value
  end

  def execute(_opcode, []), do: {:error, "trying to execute OP_EQUAL on an empty stack"}

  def execute(_opcode, [element | []]),
    do: {:error, "trying to execute OP_EQUAL on a stack with a single element #{element}"}

  def execute(_opcode, [first_element | [second_element | remaining]]) do
    case first_element == second_element do
      true -> {:ok, [1 | remaining]}
      false -> {:ok, [0 | remaining]}
    end
  end
end
