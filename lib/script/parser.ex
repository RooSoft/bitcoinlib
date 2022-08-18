defmodule BitcoinLib.Script.Parser do
  alias BitcoinLib.Script.{OpcodeManager}
  alias BitcoinLib.Script.Opcodes.Data

  @spec parse(binary()) :: list()
  def parse(script) do
    iterate(%{script: script, opcodes: [], whole_script: script})
  end

  defp iterate(%{script: <<>>, opcodes: opcodes}), do: Enum.reverse(opcodes)

  defp iterate(%{script: script, opcodes: opcodes, whole_script: whole_script}) do
    %{script: script, opcodes: opcodes, whole_script: whole_script}
    |> extract_next_opcode()
    |> iterate()
  end

  defp extract_next_opcode(%{script: script, opcodes: opcodes, whole_script: whole_script} = map) do
    case OpcodeManager.extract_from_script(script, whole_script) do
      {:opcode, opcode, remaining} ->
        %{map | script: remaining, opcodes: [opcode | opcodes]}

      {:data, data, remaining} ->
        opcode = %Data{value: data}

        %{map | script: remaining, opcodes: [opcode | opcodes]}
    end
  end
end
