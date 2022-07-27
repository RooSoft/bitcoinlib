defmodule BitcoinLib.Signing.Psbt do
  defstruct [:global, :inputs, :outputs]

  alias BitcoinLib.Signing.Psbt
  alias BitcoinLib.Signing.Psbt.{KeypairList, Global, Input, Output}

  @magic 0x70736274
  @separator 0xFF

  @spec parse(binary()) :: {:ok, %Psbt{}} | {:error, binary()}
  def parse(encoded) do
    map =
      %{encoded: encoded}
      |> base64_decode()
      |> extract_data()
      |> extract_global()
      |> extract_keypair_lists([])
      |> dispatch_keypair_lists()
      |> extract_inputs()
      |> extract_outputs()

    case Map.get(map, :error) do
      nil ->
        {:ok, %Psbt{global: map.global, inputs: map.inputs, outputs: map.outputs}}

      message ->
        {:error, message}
    end
  end

  defp base64_decode(%{encoded: encoded} = map) do
    map
    |> Map.put(:decoded, Base.decode64!(encoded))
  end

  defp extract_data(%{decoded: <<@magic::32, @separator::8, data::binary>>} = map) do
    map
    |> Map.put(:data, data)
  end

  defp extract_data(map) do
    map
    |> Map.put(:error, "magic bytes missing")
  end

  defp extract_global(%{error: error} = map) when is_binary(error) do
    map
  end

  defp extract_global(map) do
    {keypairs, remaining_data} = KeypairList.from_data(map.data)

    global = Global.from_keypair_list(keypairs)

    %{Map.put(map, :global, global) | data: remaining_data}
  end

  defp extract_keypair_lists(%{error: error} = map, _) when is_binary(error) do
    map
  end

  defp extract_keypair_lists(%{data: <<0>>} = map, keypair_lists) do
    map
    |> Map.put(:keypair_lists, Enum.reverse(keypair_lists))
  end

  defp extract_keypair_lists(%{data: <<>>} = map, keypair_lists) do
    map
    |> Map.put(:keypair_lists, Enum.reverse(keypair_lists))
  end

  defp extract_keypair_lists(%{data: remaining} = map, keypair_lists) do
    {keypair_list, remaining} = KeypairList.from_data(remaining)

    keypair_lists =
      case keypair_list do
        nil -> keypair_lists
        _ -> [keypair_list | keypair_lists]
      end

    extract_keypair_lists(%{map | data: remaining}, keypair_lists)
  end

  defp dispatch_keypair_lists(%{error: error} = map) when is_binary(error) do
    map
  end

  defp dispatch_keypair_lists(
         %{global: %Global{unsigned_tx: transaction}, keypair_lists: keypair_lists} = map
       ) do
    inputs_count = Enum.count(transaction.inputs)

    {input_keypair_lists, output_keypair_lists} =
      keypair_lists
      |> Enum.split(inputs_count)

    map
    |> Map.put(:input_keypair_lists, input_keypair_lists)
    |> Map.put(:output_keypair_lists, output_keypair_lists)
  end

  defp extract_inputs(%{error: error} = map) when is_binary(error) do
    map
  end

  defp extract_inputs(%{input_keypair_lists: keypair_lists} = map) do
    inputs =
      keypair_lists
      |> Enum.map(&Input.from_keypair_list/1)

    map
    |> Map.put(:inputs, inputs)
  end

  defp extract_outputs(%{error: error} = map) when is_binary(error) do
    map
  end

  defp extract_outputs(%{output_keypair_lists: keypair_lists} = map) do
    outputs =
      keypair_lists
      |> Enum.map(&Output.from_keypair_list/1)

    map
    |> Map.put(:outputs, outputs)
  end
end
