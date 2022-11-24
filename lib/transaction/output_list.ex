defmodule BitcoinLib.Transaction.OutputList do
  @moduledoc """
  Tasks applied to a list of outputs
  """

  alias BitcoinLib.Transaction.Output

  @doc """
  Extracts a given number of outputs from a bitstring

  ## Examples
      iex> output_count = 1
      ...> <<0xf0ca052a010000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac00000000::304>>
      ...> |> BitcoinLib.Transaction.OutputList.extract(output_count)
      {
        :ok,
        [
          %BitcoinLib.Transaction.Output{
            value: 4999990000,
            script_pub_key: [
              %BitcoinLib.Script.Opcodes.Stack.Dup{},
              %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
              %BitcoinLib.Script.Opcodes.Data{value: <<0xcbc20a7664f2f69e5355aa427045bc15e7c6c772::160>>},
              %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
              %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<0x76a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac::200>>}
            ]
          }
        ],
        <<0, 0, 0, 0>>
      }
  """
  @spec extract(bitstring(), integer()) ::
          {:ok, list(%Output{}), bitstring()} | {:error, binary()}
  def extract(remaining, count) do
    decode(remaining, count, [])
  end

  defp decode(remaining, 0, outputs), do: {:ok, outputs, remaining}

  defp decode(remaining, count, outputs) do
    case Output.extract_from(remaining) do
      {:ok, output, remaining} ->
        decode(remaining, count - 1, [output | outputs])
    end
  end
end
