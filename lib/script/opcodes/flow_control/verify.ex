defmodule BitcoinLib.Script.Opcodes.FlowControl.Verify do
  @behaviour BitcoinLib.Script.Opcode

  defstruct type: BitcoinLib.Script.Opcodes.FlowControl.Verify

  alias BitcoinLib.Script.Value

  @value 0x69

  def v do
    @value
  end

  def execute([]), do: {:error, "trying to execute OP_VERIFY on an empty stack"}

  def execute([first_element | remaining]) do
    case Value.is_true?(first_element) do
      true ->
        {:ok, remaining}

      false ->
        {:error,
         "the script is invalid, it doesn't pass the OP_VERIFY test with #{first_element} as the top stack value"}
    end
  end
end
