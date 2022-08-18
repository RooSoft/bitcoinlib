defmodule BitcoinLib.Script.Runner do
  alias BitcoinLib.Script.{Opcode}

  @spec execute(list(), list()) :: {:ok, boolean()} | {:error, binary()}
  def execute(opcodes, stack) when is_list(opcodes) do
    {:ok, stack, opcodes}
    |> execute_next_opcode
  end

  defp execute_next_opcode({:error, message}), do: {:error, message}

  defp execute_next_opcode({:ok, [1], []}), do: {:ok, true}
  defp execute_next_opcode({:ok, _, []}), do: {:ok, false}

  defp execute_next_opcode({:ok, stack, opcodes}) do
    [opcode | remaining_opcodes] = opcodes

    case Opcode.execute(opcode, stack) do
      {:ok, stack} -> execute_next_opcode({:ok, stack, remaining_opcodes})
    end
  end
end
