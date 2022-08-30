defmodule BitcoinLib.Script.Encoder do
  alias BitcoinLib.Script.{OpcodeManager}

  @doc """
  Encodes a list of opcodes into a bitstring

  ## Examples

    iex> [
    ...>   %Stack.Dup{},
    ...>   %Crypto.Hash160{},
    ...>   %Data{value: <<0x725EBAC06343111227573D0B5287954EF9B88AAE::160>>},
    ...>   %BitwiseLogic.EqualVerify{},
    ...>   %Crypto.CheckSig{}
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
