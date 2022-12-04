defmodule BitcoinLib.Transaction.Validator.Prevout do
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.Input

  @spec from_transaction(%Transaction{}, (binary() -> %Transaction{})) ::
          {:ok, list()} | {:error, binary()}
  def from_transaction(%Transaction{inputs: inputs}, get_transaction_by_id) do
    from_inputs(inputs, get_transaction_by_id)
  end

  @spec from_inputs(list(%Input{}), (binary() -> %Transaction{})) ::
          {:ok, list()} | {:error, binary()}
  def from_inputs(inputs, get_transaction_by_id) do
    with {:ok, reversed_prevouts} <- apply_extraction(inputs, get_transaction_by_id) do
      {:ok, Enum.reverse(reversed_prevouts)}
    else
      {:error, message} -> {:error, message}
    end
  end

  @spec from_input(%Input{}, (binary() -> %Transaction{})) ::
          {:ok, bitstring()} | {:error, binary()}
  def from_input(%Input{txid: txid, vout: vout}, get_transaction_by_id) do
    with {:ok, transaction} <- get_transaction_by_id.(txid) do
      {:ok, transaction |> Map.get(:outputs) |> Enum.at(vout)}
    else
      {:error, message} -> {:error, message}
    end
  end

  defp apply_extraction(inputs, get_transaction_by_id) do
    inputs
    |> Enum.map(&from_input(&1, get_transaction_by_id))
    |> Enum.reduce({:ok, []}, &validate_prevout/2)
  end

  defp validate_prevout({:error, message}, _acc), do: {:error, message}

  defp validate_prevout({:ok, prevout}, {:ok, prevouts}) do
    {:ok, [prevout | prevouts]}
  end
end
