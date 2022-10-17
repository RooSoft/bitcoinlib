defmodule BitcoinLib.Transaction.InputList do
  @moduledoc """
  Tasks applied to a list of inputs
  """

  alias BitcoinLib.Transaction.Input

  @doc """
  Extracts a given number of inputs from a bitstring

  ## Examples
    iex> input_count = 1
    ...> <<0x7b1eabe0209b1fe794124575ef807057c77ada2138ae4fa8d6c4de0398a14f3f0000000000ffffffff01f0ca052a010000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac00000000::640>>
    ...> |> BitcoinLib.Transaction.InputList.extract(input_count)
    {
      :ok,
      [
        %BitcoinLib.Transaction.Input{
          txid: "3f4fa19803dec4d6a84fae3821da7ac7577080ef75451294e71f9b20e0ab1e7b",
          vout: 0,
          script_sig: [],
          sequence: 4294967295}
      ],
      <<0x01f0ca052a010000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac00000000::312>>
    }
  """
  @spec extract(bitstring(), integer()) ::
          {:ok, list(%Input{}), bitstring()} | {:error, binary()}
  def extract(remaining, count) do
    decode(remaining, count, [])
  end

  defp decode(remaining, 0, inputs), do: {:ok, inputs, remaining}

  defp decode(remaining, count, inputs) do
    case Input.extract_from(remaining) do
      {:ok, input, remaining} ->
        decode(remaining, count - 1, [input | inputs])

      {:error, message} ->
        {:error, message}
    end
  end
end
