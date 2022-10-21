defmodule BitcoinLib.Script.Parser do
  @moduledoc """
  Converts scripts into opcode lists
  """

  alias BitcoinLib.Script.{OpcodeManager}
  alias BitcoinLib.Script.Opcodes.Data

  @doc """
  Takes a binary script and converts it into an opcode list

  ## Examples
      iex> <<0x76a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac::200>>
      ...> |> BitcoinLib.Script.Parser.parse
      {
        :ok,
        [
          %BitcoinLib.Script.Opcodes.Stack.Dup{},
          %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
          %BitcoinLib.Script.Opcodes.Data{value: <<0xcbc20a7664f2f69e5355aa427045bc15e7c6c772::160>>},
          %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
          %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<0x76a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac::200>>}
        ]
      }
  """
  @spec parse(bitstring()) :: {:ok, list()} | {:error, binary()}
  def parse(script) do
    iterate(%{script: script, opcodes: [], whole_script: script})
  end

  defp iterate(%{error: message}), do: {:error, message}

  defp iterate(%{script: <<>>, opcodes: opcodes}), do: {:ok, Enum.reverse(opcodes)}

  defp iterate(%{script: script, opcodes: opcodes, whole_script: whole_script}) do
    %{script: script, opcodes: opcodes, whole_script: whole_script}
    |> extract_next_opcode()
    |> iterate()
  end

  defp extract_next_opcode(%{script: script, opcodes: opcodes, whole_script: whole_script} = map) do
    case OpcodeManager.extract_from_script(script, whole_script) do
      {:empty_script} ->
        map

      {:error, message, remaining} ->
        map
        |> Map.put(:error, message)
        |> Map.put(:script, remaining)

      {:opcode, opcode, remaining} ->
        %{map | script: remaining, opcodes: [opcode | opcodes]}

      {:data, data, remaining} ->
        opcode = %Data{value: data}

        %{map | script: remaining, opcodes: [opcode | opcodes]}
    end
  end
end
