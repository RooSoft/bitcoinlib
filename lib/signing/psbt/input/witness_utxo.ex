defmodule BitcoinLib.Signing.Psbt.Input.WitnessUtxo do
  defstruct [:sixty_four, :pub_key]

  alias BitcoinLib.Signing.Psbt.Input.WitnessUtxo
  alias BitcoinLib.Signing.Psbt.Keypair
  alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}
  alias BitcoinLib.Signing.Psbt.CompactInteger

  def parse(keypair) do
    %{witness_utxo: witness_utxo} =
      %{keypair: keypair, witness_utxo: %WitnessUtxo{}}
      |> validate_keypair()
      |> extract_sixty_four()
      |> extract_pub_key()

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

  defp extract_sixty_four(%{witness_utxo: %{error: _message}} = map), do: map

  defp extract_sixty_four(
         %{
           keypair: %Keypair{
             value: %Value{data: <<sixty_four::binary-8, remaining::bitstring>>}
           },
           witness_utxo: witness_utxo
         } = map
       ) do
    %{map | witness_utxo: Map.put(witness_utxo, :sixty_four, Binary.to_hex(sixty_four))}
    |> Map.put(:remaining, remaining)
  end

  defp extract_pub_key(%{witness_utxo: %{error: _message}} = map), do: map

  defp extract_pub_key(%{remaining: remaining, witness_utxo: witness_utxo} = map) do
    %CompactInteger{value: pub_key_length, remaining: remaining} =
      CompactInteger.extract_from(remaining)

    <<pub_key::binary-size(pub_key_length), remaining::bitstring>> = remaining

    %{
      map
      | remaining: remaining,
        witness_utxo: Map.put(witness_utxo, :pub_key, Binary.to_hex(pub_key))
    }
  end
end
