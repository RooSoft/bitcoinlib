defmodule BitcoinLib.Signing.Psbt.Input.WitnessUtxo do
  defstruct [:amount, :script_pub_key]

  alias BitcoinLib.Signing.Psbt.Input.WitnessUtxo
  alias BitcoinLib.Signing.Psbt.Keypair
  alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}
  alias BitcoinLib.Signing.Psbt.CompactInteger

  def parse(keypair) do
    %{witness_utxo: witness_utxo} =
      %{keypair: keypair, witness_utxo: %WitnessUtxo{}}
      |> validate_keypair()
      |> extract_amount()
      |> extract_script_pub_key()

    witness_utxo
  end

  defp validate_keypair(%{keypair: keypair, witness_utxo: witness_utxo} = map) do
    case keypair.key do
      %Key{data: <<>>} ->
        map

      _ ->
        %{map | witness_utxo: Map.put(witness_utxo, :error, "invalid witness utxo key")}
    end
  end

  defp extract_amount(%{witness_utxo: %{error: _message}} = map), do: map

  defp extract_amount(
         %{
           keypair: %Keypair{
             value: %Value{data: <<amount::little-64, remaining::bitstring>>}
           },
           witness_utxo: witness_utxo
         } = map
       ) do
    %{map | witness_utxo: Map.put(witness_utxo, :amount, amount)}
    |> Map.put(:remaining, remaining)
  end

  defp extract_script_pub_key(%{witness_utxo: %{error: _message}} = map), do: map

  defp extract_script_pub_key(%{remaining: remaining, witness_utxo: witness_utxo} = map) do
    %CompactInteger{value: script_pub_key_length, remaining: remaining} =
      CompactInteger.extract_from(remaining)

    <<script_pub_key::binary-size(script_pub_key_length), remaining::bitstring>> = remaining

    %{
      map
      | remaining: remaining,
        witness_utxo: Map.put(witness_utxo, :script_pub_key, Binary.to_hex(script_pub_key))
    }
  end
end
