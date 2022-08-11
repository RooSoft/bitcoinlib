defmodule BitcoinLib.Script.Opcodes.BitwiseLogic.Equal do
  @behaviour BitcoinLib.Script.Opcode

  defstruct type: BitcoinLib.Script.Opcodes.BitwiseLogic.Equal

  @value 0x87

  def v do
    @value
  end

  def execute([]), do: {:error, "trying to execute OP_EQUAL on an empty stack"}

  def execute([_ | []]),
    do: {:error, "trying to execute OP_EQUAL on a stack with a single element"}

  def execute([first_element | [second_element | remaining]]) do
    case first_element == second_element do
      true -> {:ok, [1 | remaining]}
      false -> {:ok, [0 | remaining]}
    end
  end
end
