defmodule BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo do
  defstruct [:transaction]

  alias BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo
  alias BitcoinLib.Signing.Psbt.Keypair
  alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}

  # alias BitcoinLib.Transaction

  def parse(keypair) do
    %{keypair: keypair, non_witness_utxo: %NonWitnessUtxo{}}
    |> validate_keypair()
    |> extract_transaction()
  end

  defp validate_keypair(%{keypair: keypair, non_witness_utxo: non_witness_utxo} = map) do
    case keypair.key do
      %Key{data: <<>>} ->
        map

      _ ->
        %{
          map
          | non_witness_utxo: Map.put(non_witness_utxo, :error, "invalid non-witness utxo key")
        }
    end
  end

  defp extract_transaction(%{non_witness_utxo: %{error: _message} = non_witness_utxo}),
    do: non_witness_utxo

  defp extract_transaction(%{keypair: %Keypair{value: %Value{data: data}}}) do
    # IO.puts "----- PARSING NON-WITNESS UTXO"

    # transaction = Transaction.decode(remaining)

    # %NonWitnessUtxo{transaction: transaction}
    %NonWitnessUtxo{transaction: data}
  end
end
