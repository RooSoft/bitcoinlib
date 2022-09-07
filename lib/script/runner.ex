defmodule BitcoinLib.Script.Runner do
  @moduledoc """
  Script execution outcomes are based on this
  https://learnmeabitcoin.com/technical/script#what-makes-a-script-valid
  """
  alias BitcoinLib.Script.{Opcode}

  @spec execute(list(), list()) :: {:ok, boolean()} | {:error, binary()}
  def execute(opcodes, stack) when is_list(opcodes) do
    {stack, opcodes}
    |> execute_next_opcode
  end

  defp execute_next_opcode({[0], []}), do: {:ok, false}
  defp execute_next_opcode({[], []}), do: {:ok, false}
  defp execute_next_opcode({[_, _], []}), do: {:ok, false}
  defp execute_next_opcode({_, []}), do: {:ok, true}

  defp execute_next_opcode({stack, opcodes}) do
    [opcode | remaining_opcodes] = opcodes

    case Opcode.execute(opcode, stack) do
      {:ok, stack} -> execute_next_opcode({stack, remaining_opcodes})
    end
  end
end
