defmodule BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify do
  @behaviour BitcoinLib.Script.Opcode

  defstruct type: BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify

  alias BitcoinLib.Script.Opcodes.BitwiseLogic.Equal
  alias BitcoinLib.Script.Opcodes.FlowControl.Verify

  @value 0x88

  def v do
    @value
  end

  def execute([]), do: {:error, "trying to execute OP_EQUAL_VERIFY on an empty stack"}

  def execute([element | []]),
    do: {:error, "trying to execute OP_EQUAL_VERIFY on a stack with a single element #{element}"}

  def execute([_first_element | [_second_element | _]] = stack) do
    case Equal.execute(stack) do
      {:ok, stack} -> Verify.execute(stack)
      {:error, message} -> {:error, message}
    end
  end
end
