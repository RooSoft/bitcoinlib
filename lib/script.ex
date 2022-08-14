defmodule BitcoinLib.Script do
  alias BitcoinLib.Script.OpcodeManager

  def execute(script, stack) when is_bitstring(script) do
    {:ok, stack, script}
    |> execute_next_opcode
  end

  defp execute_next_opcode({:error, message}), do: {:error, message}

  defp execute_next_opcode({:empty_script, [1]}), do: {:ok, true}
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

  defp execute_opcode({:opcode, opcode, remaining}, stack) do
    case opcode.type.execute(stack) do
      {:ok, stack} -> {:ok, stack, remaining}
      {:error, message} -> {:error, message}
    end
  end

  defp execute_opcode({:data, data, remaining}, stack) do
    {:ok, [data | stack], remaining}
  end
end
