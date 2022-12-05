defmodule BitcoinLib.Signing.Psbt do
  @moduledoc """
  A partially signed bitcoin transaction
  """

  defstruct [:global, :inputs, :outputs]

  alias BitcoinLib.Signing.Psbt
  alias BitcoinLib.Signing.Psbt.{KeypairList, Global, InputList, OutputList}

  @type t :: Psbt

  @magic 0x70736274
  @separator 0xFF

  # TODO: document
  @spec parse(binary()) :: {:ok, Psbt.t()} | {:error, binary()}
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

    case Global.from_keypair_list(keypairs) do
      {:ok, global} -> %{Map.put(map, :global, global) | data: remaining_data}
      {:error, message} -> %{Map.put(map, :error, message) | data: remaining_data}
    end
  end

  defp extract_keypair_lists(%{error: error} = map, _) when is_binary(error) do
    map
  end

  defp extract_keypair_lists(%{data: <<>>} = map, keypair_lists) do
    map
    |> Map.put(:keypair_lists, Enum.reverse(keypair_lists))
  end

  defp extract_keypair_lists(%{data: remaining} = map, keypair_lists) do
    {keypair_list, remaining} = KeypairList.from_data(remaining)

    keypair_lists = [keypair_list | keypair_lists]

    extract_keypair_lists(%{map | data: remaining}, keypair_lists)
  end

  defp dispatch_keypair_lists(%{error: error} = map) when is_binary(error) do
    map
  end

  defp dispatch_keypair_lists(%{global: %Global{unsigned_tx: nil}, keypair_lists: []} = map) do
    map
  end

  defp dispatch_keypair_lists(%{global: %Global{unsigned_tx: nil}, keypair_lists: _} = map) do
    map
    |> Map.put(
      :error,
      "inputs and/or outputs in PSBT without an unsigned transaction in the global section"
    )
  end

  defp dispatch_keypair_lists(
         %{global: %Global{unsigned_tx: transaction}, keypair_lists: remaining_keypair_lists} =
           map
       ) do
    transaction_inputs_count = Enum.count(transaction.inputs)
    transaction_output_count = Enum.count(transaction.outputs)

    {input_keypair_lists, output_keypair_lists} =
      remaining_keypair_lists
      |> Enum.split(transaction_inputs_count)

    case output_keypair_lists |> Enum.count() < transaction_output_count do
      true ->
        map
        |> Map.put(:error, "some outputs are missing")

      false ->
        map
        |> Map.put(:input_keypair_lists, input_keypair_lists)
        |> Map.put(:output_keypair_lists, output_keypair_lists)
    end
  end

  defp extract_inputs(%{error: error} = map) when is_binary(error) do
    map
  end

  defp extract_inputs(%{input_keypair_lists: keypair_lists} = map) do
    case InputList.extract(keypair_lists) do
      {:ok, inputs} ->
        map
        |> Map.put(:inputs, inputs)

      {:error, message} ->
        map
        |> Map.put(:error, message)
    end
  end

  defp extract_outputs(%{error: error} = map) when is_binary(error) do
    map
  end

  defp extract_outputs(%{error: error} = map) when is_binary(error) do
    map
  end

  defp extract_outputs(%{output_keypair_lists: keypair_lists} = map) do
    case OutputList.extract(keypair_lists) do
      {:ok, outputs} ->
        map
        |> Map.put(:outputs, outputs)

      {:error, message} ->
        map
        |> Map.put(:error, message)
    end
  end
end
