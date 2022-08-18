defmodule BitcoinLib.Script.Opcodes.BitwiseLogic.Equal do
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
