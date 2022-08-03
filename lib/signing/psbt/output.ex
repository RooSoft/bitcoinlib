defmodule BitcoinLib.Signing.Psbt.Output do
  defstruct unknowns: []

  alias BitcoinLib.Signing.Psbt.{Keypair, KeypairList, Output}

  def from_keypair_list(nil) do
    nil
  end

  def from_keypair_list(%KeypairList{} = keypair_list) do
    keypair_list.keypairs
    |> validate_keys
    |> dispatch_keypairs
  end

  defp validate_keys(keypairs) do
    keys =
      keypairs
      |> Enum.map(& &1.key)

    duplicate_keys = keys -- Enum.uniq(keys)

    case duplicate_keys do
      [] ->
        {:ok, keypairs}

      duplicates ->
        {:error, "duplicate keys: #{inspect(duplicates)}"}
    end
  end

  defp dispatch_keypairs({:error, message}) do
    %{error: message}
  end

  defp dispatch_keypairs({:ok, keypairs}) do
    keypairs
    |> Enum.reduce(%Output{}, &dispatch_keypair/2)
  end

  defp dispatch_keypair(%Keypair{key: key, value: value}, output) do
    case key.type do
      _ -> add_unknown(output, key, value)
    end
  end

  defp add_unknown(input, key, value) do
    input
    |> Map.put(:unknowns, [{key, value} | input.unknowns])
  end
end
