defmodule BitcoinLib.Signing.Psbt.InputList do
  alias BitcoinLib.Signing.Psbt.Input

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
      |> Enum.find_value(fn {status, value} -> if status == :error, do: {status, value} end)

    case error do
      nil -> {:ok, computed_inputs}
      {:error, message} -> {:error, message}
    end
  end

  defp extract_values({:error, _message} = map) do
    map
  end

  defp extract_values({:ok, computed_inputs}) do
    inputs =
      computed_inputs
      |> Enum.map(&get_inputs/1)
      |> Enum.filter(&(!is_nil(&1)))

    {:ok, inputs}
  end

  defp get_inputs(computed_input), do: elem(computed_input, 1)
end
