defmodule BitcoinLib.Script do
  alias BitcoinLib.Script.OpcodeManager

  @spec execute(bitstring(), list()) :: {:ok, boolean()} | {:error, binary()}
  def execute(script, stack) when is_bitstring(script) do
    {:ok, stack, script, script}
    |> execute_next_opcode
  end

  defp execute_next_opcode({:error, message}), do: {:error, message}

  defp execute_next_opcode({:empty_script, [1]}), do: {:ok, true}
  defp execute_next_opcode({:empty_script, _}), do: {:ok, false}

  defp execute_next_opcode({:ok, stack, script, whole_script}) do
    script
    |> OpcodeManager.extract_from_script(whole_script)
    |> execute_opcode(stack, whole_script)
    |> execute_next_opcode
  end

  defp execute_opcode({:empty_script}, stack, _whole_script), do: {:empty_script, stack}

  defp execute_opcode({:error, message}, _stack, _whole_script) do
    {:error, message}
  end

  defp execute_opcode({:opcode, opcode, remaining}, stack, whole_script) do
    case opcode.type.execute(opcode, stack) do
      {:ok, stack} -> {:ok, stack, remaining, whole_script}
      {:error, message} -> {:error, message}
    end
  end

  defp execute_opcode({:data, data, remaining}, stack, whole_script) do
    {:ok, [data | stack], remaining, whole_script}
  end
end
