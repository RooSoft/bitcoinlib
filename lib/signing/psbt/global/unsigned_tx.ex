defmodule BitcoinLib.Signing.Psbt.Global.UnsignedTx do
  alias BitcoinLib.Transaction

  def parse(keypair) do
    keypair
    |> validate_keypair()
    |> decode_transaction()
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

      {:ok, unsigned_tx} ->
        case Transaction.check_if_unsigned(unsigned_tx) do
          true -> {:ok, unsigned_tx}
          false -> {:error, "the supposedly unsigned transaction has already been signed"}
        end
    end
  end
end
