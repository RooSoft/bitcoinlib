defmodule BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo do
  @moduledoc """
  A non-witness UTXO in a partially signed bitcoin transaction's input
  """

  defstruct [:transaction]

  alias BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo
  alias BitcoinLib.Signing.Psbt.Keypair
  alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}
  alias BitcoinLib.Transaction

  # TODO: document
  def parse(keypair) do
    %{keypair: keypair}
    |> validate_keypair()
    |> extract_transaction()
    ## TODO: these conditions fail on a valid P2PKH PSBT, please review before reinstating them
    #   |> validate_script_pub_keys()
    |> create_output()
  end

  defp create_output(%{error: message}), do: {:error, message}

  defp create_output(%{transaction: transaction}),
    do: {:ok, %NonWitnessUtxo{transaction: transaction}}

  defp validate_keypair(%{keypair: keypair} = map) do
    case keypair.key do
      %Key{data: <<>>} ->
        map

      _ ->
        set_error(map, "invalid non-witness utxo key")
    end
  end

  defp extract_transaction(%{error: _} = map), do: map

  defp extract_transaction(%{keypair: %Keypair{value: %Value{data: data}}} = map) do
    case Transaction.decode(data) do
      {:ok, transaction, <<>>} ->
        set_transaction(map, transaction)

      {:error, message} ->
        set_error(map, message)
    end
  end

  # defp validate_script_pub_keys(%{non_witness_utxo: %{error: _message}} = map),
  #   do: map

  # defp validate_script_pub_keys(
  #        %{
  #          non_witness_utxo: %NonWitnessUtxo{transaction: %Transaction{outputs: outputs}}
  #        } = map
  #      ) do
  #   non_witness_type =
  #     outputs
  #     |> Enum.map(&get_script_type/1)
  #     |> Enum.filter(&(&1 != :non_witness))
  #     |> List.first()

  #   case non_witness_type do
  #     nil ->
  #       map

  #     :witness ->
  #       set_error(map, "a non-witness UTXO contains a witness script pub key")

  #     :unknown ->
  #       set_error(map, "a non-witness UTXO contains an unknown script pub key")
  #   end
  # end

  # defp get_script_type(%Output{script_pub_key: script_pub_key}) do
  #   case Script.identify(script_pub_key) do
  #     :p2pk -> :non_witness
  #     :p2pkh -> :non_witness
  #     :p2sh -> :non_witness
  #     :p2wpkh -> :witness
  #     :p2wsh -> :witness
  #     _ -> :unknown
  #   end
  # end

  defp set_transaction(map, transaction) do
    Map.put(map, :transaction, transaction)
  end

  defp set_error(map, message) do
    Map.put(map, :error, message)
  end
end
