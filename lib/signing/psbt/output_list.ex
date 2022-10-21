defmodule BitcoinLib.Signing.Psbt.OutputList do
  alias BitcoinLib.Signing.Psbt.Output

  # TODO: document
  def extract(keypair_lists) do
    keypair_lists
    |> call()
    |> validate_result()
    |> extract_values()
  end

  defp call(keypair_lists) do
    keypair_lists
    |> Enum.map(&Output.from_keypair_list/1)
  end

  defp validate_result([]), do: {:ok, []}

  defp validate_result(computed_outputs) do
    error =
      computed_outputs
      |> Enum.find_value(&extract_error/1)

    case error do
      nil -> {:ok, computed_outputs}
      message -> {:error, message}
    end
  end

  defp extract_error(nil) do
    nil
  end

  defp extract_error(output) do
    output
    |> Map.get(:error)
  end

  defp extract_values({:error, message}), do: {:error, message}

  defp extract_values({:ok, computed_outputs}) do
    outputs =
      computed_outputs
      |> Enum.filter(&(!is_nil(&1)))

    {:ok, outputs}
  end
end
