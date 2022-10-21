defmodule BitcoinLib.Signing.Psbt.InputList do
  alias BitcoinLib.Signing.Psbt.Input

  # TODO: document
  def extract(keypair_lists) do
    keypair_lists
    |> call()
    |> validate_result()
    |> extract_values()
  end

  defp call(keypair_lists) do
    keypair_lists
    |> Enum.map(&Input.from_keypair_list/1)
  end

  defp validate_result(computed_inputs) do
    error =
      computed_inputs
      |> Enum.find_value(fn input ->
        Map.get(input, :error)
      end)

    case error do
      nil -> {:ok, computed_inputs}
      message -> {:error, message}
    end
  end

  defp extract_values({:error, message}), do: {:error, message}

  defp extract_values({:ok, computed_inputs}) do
    inputs =
      computed_inputs
      |> Enum.filter(&(!is_nil(&1)))

    {:ok, inputs}
  end
end
