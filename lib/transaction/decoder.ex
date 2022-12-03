defmodule BitcoinLib.Transaction.Decoder do
  @moduledoc """
  Transform binaries into Transactions
  """

  alias BitcoinLib.Transaction
  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Transaction.{InputList, OutputList, Input}

  @marker 0
  @flag 1
  @byte 8

  @doc """
  Converts a bitstring into a %Transaction{} and the remaining unused data

  ## Examples
      iex> <<0x01000000017b1eabe0209b1fe794124575ef807057c77ada2138ae4fa8d6c4de0398a14f3f0000000000ffffffff01f0ca052a010000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac92040000::680>>
      ...> |> BitcoinLib.Transaction.Decoder.to_struct()
      {
        :ok,
        %BitcoinLib.Transaction{
          version: 1,
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
          locktime: 1170,
          segwit?: false
        },
        <<>>
      }
  """
  @spec to_struct(bitstring()) :: {:ok, %Transaction{}, bitstring()} | {:error, binary()}
  def to_struct(encoded_transaction) do
    # see https://github.com/bitcoin/bips/blob/master/bip-0144.mediawiki#hashes
    version_specific_extract(encoded_transaction)
  end

  # Extracts a witness transaction
  defp version_specific_extract(
         <<version::little-32, @marker::8, @flag::8, remaining::bitstring>>
       ) do
    result =
      %{witnesses: [], remaining: remaining, coinbase?: false}
      |> extract_input_count
      |> extract_inputs()
      |> extract_output_count
      |> extract_outputs
      |> extract_witnesses
      |> extract_locktime
      |> validate_outputs

    case result do
      %{error: message} ->
        {:error, message}

      %{
        inputs: inputs,
        outputs: outputs,
        witnesses: witnesses,
        locktime: locktime,
        remaining: remaining,
        coinbase?: coinbase?
      } ->
        {:ok,
         %Transaction{
           version: version,
           inputs: inputs,
           outputs: outputs,
           witness: witnesses,
           locktime: locktime,
           segwit?: true,
           coinbase?: coinbase?
         }, remaining}
    end
  end

  # Extracts a non-witness transaction
  defp version_specific_extract(remaining) do
    result =
      %{remaining: remaining, coinbase?: false}
      |> extract_version
      |> extract_input_count
      |> extract_inputs()
      |> extract_output_count
      |> extract_outputs
      |> extract_locktime
      |> validate_outputs

    case result do
      %{error: message} ->
        {:error, message}

      %{
        version: version,
        inputs: inputs,
        outputs: outputs,
        locktime: locktime,
        remaining: remaining,
        coinbase?: coinbase?
      } ->
        {:ok,
         %Transaction{
           version: version,
           inputs: inputs,
           outputs: outputs,
           locktime: locktime,
           segwit?: false,
           coinbase?: coinbase?
         }, remaining}
    end
  end

  defp extract_version(%{remaining: <<version::little-32, remaining::bitstring>>} = map) do
    %{map | remaining: remaining}
    |> Map.put(:version, version)
  end

  defp extract_input_count(%{remaining: remaining} = map) do
    %CompactInteger{value: input_count, remaining: remaining} =
      CompactInteger.extract_from(remaining, :little_endian)

    %{map | remaining: remaining}
    |> Map.put(:input_count, input_count)
  end

  defp extract_inputs(%{input_count: input_count, remaining: remaining} = map) do
    case InputList.extract(remaining, input_count) do
      {:ok,
       [%Input{txid: "0000000000000000000000000000000000000000000000000000000000000000"}] =
           inputs, remaining} ->
        %{map | remaining: remaining}
        |> Map.put(:inputs, inputs)
        |> Map.put(:coinbase?, true)

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
      CompactInteger.extract_from(remaining, :little_endian)

    %{map | remaining: remaining}
    |> Map.put(:output_count, output_count)
  end

  defp extract_witnesses(%{error: message}), do: %{error: message}

  defp extract_witnesses(%{inputs: inputs, remaining: remaining} = map) do
    {witnesses, remaining} =
      inputs
      |> Enum.reduce(
        {[], remaining},
        fn _input, {witnesses, remaining} ->
          {new_witnesses, remaining} = extract_witness_for_input(remaining)

          {[new_witnesses |> Enum.reverse() | witnesses], remaining}
        end
      )

    %{map | witnesses: witnesses |> Enum.reverse(), remaining: remaining}
  end

  defp extract_witness_for_input(remaining) do
    %CompactInteger{value: witness_count, remaining: remaining} =
      CompactInteger.extract_from(remaining, :little_endian)

    if witness_count > 0 do
      1..witness_count
      |> Enum.reduce({[], remaining}, fn _, {witnesses, remaining} ->
        %CompactInteger{value: witness_length, remaining: remaining} =
          CompactInteger.extract_from(remaining, :little_endian)

        bits_witness_length = witness_length * @byte

        <<witness::bitstring-size(bits_witness_length), remaining::bitstring>> = remaining

        {[witness | witnesses], remaining}
      end)
    else
      {[], remaining}
    end
  end

  defp extract_outputs(%{error: message}), do: %{error: message}

  defp extract_outputs(%{output_count: output_count, remaining: remaining} = map) do
    case OutputList.extract(remaining, output_count) do
      {:ok, outputs, remaining} ->
        %{map | remaining: remaining}
        |> Map.put(:outputs, Enum.reverse(outputs))
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
