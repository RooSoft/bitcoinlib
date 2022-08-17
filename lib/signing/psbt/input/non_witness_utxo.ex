defmodule BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo do
  defstruct [:transaction]

  alias BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo
  alias BitcoinLib.Signing.Psbt.Keypair
  alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}
  alias BitcoinLib.Script

  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.Output

  def parse(keypair) do
    %{keypair: keypair, non_witness_utxo: %NonWitnessUtxo{}}
    |> validate_keypair()
    |> extract_transaction()
    |> validate_script_pub_keys()
    |> Map.get(:non_witness_utxo)
  end

  defp validate_keypair(%{keypair: keypair} = map) do
    case keypair.key do
      %Key{data: <<>>} ->
        map

      _ ->
        set_error(map, "invalid non-witness utxo key")
    end
  end

  defp extract_transaction(%{non_witness_utxo: %{error: _message}} = map),
    do: map

  defp extract_transaction(%{keypair: %Keypair{value: %Value{data: data}}} = map) do
    case Transaction.decode(data) do
      {:ok, transaction} ->
        set_transaction(map, transaction)

      {:error, message} ->
        set_error(map, message)
    end
  end

  defp validate_script_pub_keys(%{non_witness_utxo: %{error: _message}} = map),
    do: map

  defp validate_script_pub_keys(
         %{
           non_witness_utxo: %NonWitnessUtxo{transaction: %Transaction{outputs: outputs}}
         } = map
       ) do
    non_witness_type =
      outputs
      |> Enum.map(&get_script_type/1)
      |> Enum.filter(&(&1 != :non_witness))
      |> List.first()

    case non_witness_type do
      nil ->
        map

      :witness ->
        set_error(map, "a non-witness UTXO contains a witness script pub key")

      :unknown ->
        set_error(map, "a non-witness UTXO contains an unknown script pub key")
    end
  end

  defp get_script_type(%Output{script_pub_key: script_pub_key}) do
    case Script.identify(script_pub_key) do
      :p2pk -> :non_witness
      :p2pkh -> :non_witness
      :p2sh -> :non_witness
      :p2wpkh -> :witness
      :p2wsh -> :witness
      _ -> :unknown
    end
  end

  defp set_transaction(%{non_witness_utxo: non_witness_utxo} = map, transaction) do
    %{map | non_witness_utxo: Map.put(non_witness_utxo, :transaction, transaction)}
  end

  defp set_error(%{non_witness_utxo: non_witness_utxo} = map, message) do
    %{
      map
      | non_witness_utxo: Map.put(non_witness_utxo, :error, message)
    }
  end
end
