defmodule BitcoinLib.Script do
  alias BitcoinLib.Script.OpcodeManager

  def execute(script, input) when is_bitstring(script) do
    stack = input |> Enum.reverse()

    {:ok, stack, script}
    |> execute_next_opcode
  end

  defp execute_next_opcode({:error, message}), do: {:error, message}

  defp execute_next_opcode({:empty_script, [true]}), do: {:ok, true}
  defp execute_next_opcode({:empty_script, _}), do: {:ok, false}

  defp execute_next_opcode({:ok, stack, script}) do
    script
    |> OpcodeManager.extract_from_script()
    |> execute_opcode(stack)
    |> execute_next_opcode
  end

  defp execute_opcode({:empty_script}, stack), do: {:empty_script, stack}

  defp execute_opcode({:error, message, _remaining}, _stack) do
    {:error, message}
  end

  defp execute_opcode({:ok, _, remaining}, stack) do
    {:ok, stack, remaining}
  end
end
