defmodule BitcoinLib.Signing.Psbt.Global.UnsignedTx do
  @moduledoc """
  An unsigned transaction in the global section of a partially signed bitcoin transaction
  """

  alias BitcoinLib.Transaction

  # TODO: document
  def parse(keypair) do
    keypair
    |> validate_keypair()
    |> decode_transaction()
    |> validate_witness()
  end

  defp validate_keypair(keypair) do
    case keypair.key.data do
      "" ->
        {:ok, keypair}

      value ->
        {:error, "PSBT_GLOBAL_UNSIGNED_TX key shouldn't contain a value (#{inspect(value)})"}
    end
  end

  defp decode_transaction({:error, message}) do
    {:error, message}
  end

  defp decode_transaction({:ok, keypair}) do
    case Transaction.decode(keypair.value.data) do
      {:error, message} ->
        {:error, message}

      {:ok, unsigned_tx, <<>>} ->
        case Transaction.check_if_unsigned(unsigned_tx) do
          true -> {:ok, unsigned_tx}
          false -> {:error, "the supposedly unsigned transaction has already been signed"}
        end
    end
  end

  defp validate_witness({:error, message}), do: {:error, message}

  defp validate_witness({:ok, %Transaction{segwit?: true, witness: witness} = transaction}) do
    case get_non_empty_witness_count(witness) do
      0 -> {:error, "unsigned tx serialized with witness serialization format"}
      _ -> {:ok, transaction}
    end
  end

  defp validate_witness({:ok, transaction}), do: {:ok, transaction}

  defp get_non_empty_witness_count(witness) do
    witness
    |> Enum.concat()
    |> Enum.count()
  end
end
