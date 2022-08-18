defmodule BitcoinLib.Script.Parser do
  alias BitcoinLib.Script.{OpcodeManager}

  def parse(script),
    do: iterate(%{script: script, opcodes: [], whole_script: script})

  defp iterate(%{script: <<>>, opcodes: opcodes}), do: opcodes

  defp iterate(%{script: script, opcodes: opcodes, whole_script: whole_script}) do
    %{script: script, opcodes: opcodes, whole_script: whole_script}
    |> extract_next_opcode()
    |> iterate()
  end

  defp extract_next_opcode(%{script: script, opcodes: opcodes, whole_script: whole_script} = map) do
    case OpcodeManager.extract_from_script(script, whole_script) do
      {:opcode, opcode, remaining} ->
        %{map | opcodes: [opcode | opcodes], script: remaining}
    end
  end
end
