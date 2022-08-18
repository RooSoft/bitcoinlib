defmodule BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify do
  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.BitwiseLogic.Equal
  alias BitcoinLib.Script.Opcodes.FlowControl.Verify

  @value 0x88

  def v do
    @value
  end

  def execute(_opcode, []), do: {:error, "trying to execute OP_EQUAL_VERIFY on an empty stack"}

  def execute(_opcode, [element | []]),
    do: {:error, "trying to execute OP_EQUAL_VERIFY on a stack with a single element #{element}"}

  def execute(_opcode, [_first_element | [_second_element | _]] = stack) do
    case Equal.execute(%Equal{}, stack) do
      {:ok, stack} -> Verify.execute(%Verify{}, stack)
      {:error, message} -> {:error, message}
    end
  end
end
