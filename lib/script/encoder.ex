defmodule BitcoinLib.Script.Encoder do
  @moduledoc """
  Used to encode scripts in the bitstring format
  """

  alias BitcoinLib.Script.{OpcodeManager}

  @doc """
  Encodes a list of opcodes into a bitstring

  ## Examples
      iex> [
      ...>   %BitcoinLib.Script.Opcodes.Stack.Dup{},
      ...>   %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
      ...>   %BitcoinLib.Script.Opcodes.Data{value: <<0x725EBAC06343111227573D0B5287954EF9B88AAE::160>>},
      ...>   %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
      ...>   %BitcoinLib.Script.Opcodes.Crypto.CheckSig{}
      ...> ] |> BitcoinLib.Script.Encoder.to_bitstring()
      <<0x76A914725EBAC06343111227573D0B5287954EF9B88AAE88AC::200>>
  """
  @spec to_bitstring(list()) :: bitstring()
  def to_bitstring(script) when is_list(script) do
    %{script: script, encoded: <<>>}
    |> iterate
  end

  defp iterate(%{script: [], encoded: encoded}), do: encoded

  defp iterate(%{script: [opcode | remaining], encoded: encoded}) do
    encoded_opcode = OpcodeManager.encode_opcode(opcode)

    iterate(%{script: remaining, encoded: <<encoded::bitstring, encoded_opcode::bitstring>>})
  end
end
