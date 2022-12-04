defmodule BitcoinLib.Transaction.Encoder do
  @moduledoc """
  Can convert a Transaction into binary formats
  """

  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Input, Output}
  alias BitcoinLib.Transaction.Witnesses.{P2wpkhWitness}
  alias BitcoinLib.Signing.Psbt.CompactInteger

  @flag 1
  @marker 0
  @byte 8

  @doc """
  Encodes a transaction in binary format from a structure

  ## Examples
      iex> %BitcoinLib.Transaction{
      ...>   inputs: [
      ...>     %BitcoinLib.Transaction.Input{
      ...>       script_sig: nil,
      ...>       sequence: 0xFFFFFFFF,
      ...>       txid: "5e2383defe7efcbdc9fdd6dba55da148b206617bbb49e6bb93fce7bfbb459d44",
      ...>       vout: 1
      ...>     }
      ...>   ],
      ...>   outputs: [
      ...>     %BitcoinLib.Transaction.Output{
      ...>       script_pub_key: [
      ...>         %BitcoinLib.Script.Opcodes.Stack.Dup{},
      ...>         %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
      ...>         %BitcoinLib.Script.Opcodes.Data{value: <<0xf86f0bc0a2232970ccdf4569815db500f1268361::160>>},
      ...>         %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
      ...>         %BitcoinLib.Script.Opcodes.Crypto.CheckSig{}
      ...>       ],
      ...>       value: 129000000
      ...>     }
      ...>   ],
      ...>   locktime: 0,
      ...>   version: 1
      ...> }
      ...> |> BitcoinLib.Transaction.Encoder.from_struct()
      <<1, 0, 0, 0>> <> # version
      <<1>> <>          # input_count
      <<0x449d45bbbfe7fc93bbe649bb7b6106b248a15da5dbd6fdc9bdfc7efede83235e0100000000ffffffff::328>> <> # inputs
      <<1>> <>          # output_count
      <<0x4062b007000000001976a914f86f0bc0a2232970ccdf4569815db500f126836188ac::272>> <> # outputs
      <<0, 0, 0, 0>>    # locktime
  """
  @spec from_struct(Transaction.t()) :: bitstring()
  def from_struct(%Transaction{} = transaction) do
    %{transaction: transaction, encoded: <<>>}
    |> append_version
    |> maybe_append_marker
    |> append_input_count
    |> append_inputs
    |> append_output_count
    |> append_outputs
    |> maybe_append_witnesses
    |> append_locktime
    |> Map.get(:encoded)
  end

  @doc """
  Specific encoding meant to generate Transaction ID's

  ## Examples

      iex> %BitcoinLib.Transaction{
      ...>   inputs: [
      ...>     %BitcoinLib.Transaction.Input{
      ...>       script_sig: nil,
      ...>       sequence: 0xFFFFFFFF,
      ...>       txid: "5e2383defe7efcbdc9fdd6dba55da148b206617bbb49e6bb93fce7bfbb459d44",
      ...>       vout: 1
      ...>     }
      ...>   ],
      ...>   outputs: [
      ...>     %BitcoinLib.Transaction.Output{
      ...>       script_pub_key: [
      ...>         %BitcoinLib.Script.Opcodes.Stack.Dup{},
      ...>         %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
      ...>         %BitcoinLib.Script.Opcodes.Data{value: <<0xf86f0bc0a2232970ccdf4569815db500f1268361::160>>},
      ...>         %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
      ...>         %BitcoinLib.Script.Opcodes.Crypto.CheckSig{}
      ...>       ],
      ...>       value: 129000000
      ...>     }
      ...>   ],
      ...>   locktime: 0,
      ...>   version: 1
      ...> }
      ...> |> BitcoinLib.Transaction.Encoder.for_txid()
      <<0x0100000001449d45bbbfe7fc93bbe649bb7b6106b248a15da5dbd6fdc9bdfc7efede83235e0100000000ffffffff014062b007000000001976a914f86f0bc0a2232970ccdf4569815db500f126836188ac00000000::680>>
  """
  def for_txid(Transaction.t() = transaction) do
    %{transaction: transaction, encoded: <<>>}
    |> append_version
    |> append_input_count
    |> append_inputs
    |> append_output_count
    |> append_outputs
    |> append_locktime
    |> Map.get(:encoded)
  end

  defp append_version(%{transaction: %Transaction{version: version}, encoded: encoded} = map) do
    %{map | encoded: <<encoded::binary, version::little-32>>}
  end

  # No witness, and thus the marker shouldn't be added
  defp maybe_append_marker(%{transaction: %Transaction{witness: []}} = map), do: map

  # Add a marker since witnesses are present
  defp maybe_append_marker(
         %{transaction: %Transaction{witness: _witness}, encoded: encoded} = map
       ) do
    %{map | encoded: <<encoded::binary, @marker::@byte, @flag::@byte>>}
  end

  defp append_input_count(%{transaction: %Transaction{inputs: inputs}, encoded: encoded} = map) do
    encoded_input_count =
      inputs
      |> Enum.count()
      |> CompactInteger.encode()

    %{map | encoded: <<encoded::bitstring, encoded_input_count::bitstring>>}
  end

  defp append_inputs(%{transaction: %Transaction{inputs: inputs}, encoded: encoded} = map) do
    encoded_with_inputs =
      inputs
      |> Enum.map(&Input.encode(&1))
      |> Enum.reduce(encoded, fn encoded_input, acc ->
        <<acc::bitstring, encoded_input::bitstring>>
      end)

    %{map | encoded: encoded_with_inputs}
  end

  defp append_output_count(%{transaction: %Transaction{outputs: outputs}, encoded: encoded} = map) do
    encoded_output_count =
      outputs
      |> Enum.count()
      |> CompactInteger.encode()

    %{map | encoded: <<encoded::bitstring, encoded_output_count::bitstring>>}
  end

  defp append_outputs(%{transaction: %Transaction{outputs: outputs}, encoded: encoded} = map) do
    encoded_with_outputs =
      outputs
      |> Enum.map(&Output.encode(&1))
      |> Enum.reduce(encoded, fn encoded_output, acc ->
        <<acc::bitstring, encoded_output::bitstring>>
      end)

    %{map | encoded: encoded_with_outputs}
  end

  defp maybe_append_witnesses(%{transaction: %Transaction{witness: []}} = map), do: map

  defp maybe_append_witnesses(
         %{transaction: %Transaction{witness: [[signature, public_key]]}, encoded: encoded} = map
       ) do
    encoded_witness = P2wpkhWitness.encode(signature, public_key)

    %{map | encoded: <<encoded::bitstring, encoded_witness::bitstring>>}
  end

  defp append_locktime(%{transaction: %Transaction{locktime: locktime}, encoded: encoded} = map) do
    %{map | encoded: <<encoded::bitstring, locktime::little-32>>}
  end
end
