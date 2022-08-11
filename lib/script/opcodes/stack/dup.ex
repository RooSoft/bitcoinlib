defmodule BitcoinLib.Script.Opcodes.Stack.Dup do
  @behaviour BitcoinLib.Script.Opcode

  defstruct type: BitcoinLib.Script.Opcodes.Stack.Dup

  @value 0x76

  def v do
    @value
  end

  def execute([]), do: {:error, "trying to execute OP_DUP on an empty stack"}

  def execute([first_element | _] = stack) do
    {:ok, [first_element | stack]}
  end
end
