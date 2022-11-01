defmodule BitcoinLib.Transaction.Decoder do
  @moduledoc """
  Transform binaries into Transactions
  """

  alias BitcoinLib.Transaction
  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Transaction.{InputList, OutputList}

  @marker 0
  @flag 1
  @byte 8

  @doc """
  Converts a bitstring into a %Transaction{}

  ## Examples
      iex> <<0x01000000017b1eabe0209b1fe794124575ef807057c77ada2138ae4fa8d6c4de0398a14f3f0000000000ffffffff01f0ca052a010000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac92040000::680>>
      ...> |> BitcoinLib.Transaction.Decoder.to_struct()
      {
        :ok,
        %BitcoinLib.Transaction{
          version: 1,
          id: "b1caa607a324ed9132c3d894d2cf7a22d59cdb4022bd8827c49e2f0d8ca018c6",
          inputs: [
            %BitcoinLib.Transaction.Input{
              txid: "3f4fa19803dec4d6a84fae3821da7ac7577080ef75451294e71f9b20e0ab1e7b",
              vout: 0,
              script_sig: [],
              sequence: 4294967295
            }
          ],
          outputs: [
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
          locktime: 1170
        }
      }
  """
  @spec to_struct(bitstring()) :: {:ok, %Transaction{}} | {:error, binary()}
  def to_struct(encoded_transaction) do
    # see https://github.com/bitcoin/bips/blob/master/bip-0144.mediawiki#hashes
    Transaction.id_from_encoded_transaction(encoded_transaction)
    |> version_specific_extract(encoded_transaction)
  end

  # Extracts a witness transaction
  defp version_specific_extract(
         id,
         <<version::little-32, @marker::8, @flag::8, remaining::bitstring>>
       ) do
    result =
      %{remaining: remaining, witness_signature?: true}
      |> extract_input_count
      |> extract_inputs
      |> extract_output_count
      |> extract_outputs
      |> extract_witness
      |> extract_locktime
      |> validate_outputs

    case result do
      %{error: message} ->
        {:error, message}

      %{inputs: inputs, outputs: outputs, witness: witness, locktime: locktime} ->
        {:ok,
         %Transaction{
           id: id,
           version: version,
           inputs: inputs,
           outputs: outputs,
           witness: witness,
           locktime: locktime
         }}
    end
  end

  # Extracts a non-witness transaction
  defp version_specific_extract(id, remaining) do
    result =
      %{remaining: remaining, witness_signature?: false}
      |> extract_version
      |> extract_input_count
      |> extract_inputs
      |> extract_output_count
      |> extract_outputs
      |> extract_locktime
      |> validate_outputs

    case result do
      %{error: message} ->
        {:error, message}

      %{version: version, inputs: inputs, outputs: outputs, locktime: locktime} ->
        {:ok,
         %Transaction{
           id: id,
           version: version,
           inputs: inputs,
           outputs: outputs,
           locktime: locktime
         }}
    end
  end

  defp extract_version(%{remaining: <<version::little-32, remaining::bitstring>>} = map) do
    %{map | remaining: remaining}
    |> Map.put(:version, version)
  end

  defp extract_input_count(%{remaining: remaining} = map) do
    %CompactInteger{value: input_count, remaining: remaining} =
      CompactInteger.extract_from(remaining, :big_endian)

    %{map | remaining: remaining}
    |> Map.put(:input_count, input_count)
  end

  defp extract_inputs(%{input_count: input_count, remaining: remaining} = map) do
    case InputList.extract(remaining, input_count) do
      {:ok, inputs, remaining} ->
        %{map | remaining: remaining}
        |> Map.put(:inputs, Enum.reverse(inputs))

      {:error, message} ->
        Map.put(map, :error, "in transaction inputs, " <> message)
    end
  end

  defp extract_output_count(%{error: message}), do: %{error: message}

  defp extract_output_count(%{remaining: remaining} = map) do
    %CompactInteger{value: output_count, remaining: remaining} =
      CompactInteger.extract_from(remaining, :big_endian)

    %{map | remaining: remaining}
    |> Map.put(:output_count, output_count)
  end

  defp extract_witness(%{error: message}), do: %{error: message}

  defp extract_witness(%{remaining: remaining, witness_signature?: witness_signature?} = map) do
    %CompactInteger{value: witness_count, remaining: remaining} =
      CompactInteger.extract_from(remaining, :big_endian)

    case witness_count == 0 && witness_signature? do
      true ->
        %{error: "unsigned tx serialized with witness serialization format"}

      false ->
        {witness, remaining} = extract_witness_list([], remaining, witness_count)

        %{map | remaining: remaining}
        |> Map.put(:witness, witness)
    end
  end

  defp extract_witness_list(witnesses, remaining, 0), do: {witnesses, remaining}

  defp extract_witness_list(witnesses, remaining, count) do
    %CompactInteger{value: witness_length, remaining: remaining} =
      CompactInteger.extract_from(remaining, :big_endian)

    bits_witness_length = witness_length * @byte

    <<witness::bitstring-size(bits_witness_length), remaining::bitstring>> = remaining

    extract_witness_list([witness | witnesses], remaining, count - 1)
  end

  defp extract_outputs(%{error: message}), do: %{error: message}

  defp extract_outputs(%{output_count: output_count, remaining: remaining} = map) do
    case OutputList.extract(remaining, output_count) do
      {:ok, outputs, remaining} ->
        %{map | remaining: remaining}
        |> Map.put(:outputs, Enum.reverse(outputs))

      {:error, message} ->
        Map.put(map, :error, "in transaction outputs, " <> message)
    end
  end

  defp extract_locktime(%{error: _message} = map), do: map

  defp extract_locktime(%{remaining: remaining} = map) do
    <<locktime::little-32, remaining::bitstring>> = remaining

    %{map | remaining: remaining}
    |> Map.put(:locktime, locktime)
  end

  defp validate_outputs(%{error: _message} = map), do: map

  defp validate_outputs(%{outputs: outputs} = map) do
    error =
      outputs
      |> Enum.find_value(fn output ->
        Map.get(output, :error)
      end)

    case error do
      nil ->
        map

      message ->
        map
        |> Map.put(:error, message)
    end
  end
end
