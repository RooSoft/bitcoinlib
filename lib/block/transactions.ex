defmodule BitcoinLib.Block.Transactions do
  @moduledoc """
  Converts a list of bytes into a list of transactions
  """

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Transaction

  @spec decode(binary()) :: {:ok, list()} | {:error, binary()}
  def decode(transactions_data) do
    %CompactInteger{
      remaining: remaining,
      value: transaction_count
    } = CompactInteger.extract_from(transactions_data)

    with {:ok, transactions} <- scan(transaction_count, remaining) do
      {:ok, transactions}
    else
      {:error, message} -> {:error, message}
    end
  end

  defp scan(expected_transaction_count, remaininig) do
    with {:ok, transaction} <- Transaction.decode(remaininig) do
      transactions = [transaction]

      validate(expected_transaction_count, transactions)
    else
      {:error, message} -> {:error, message}
    end
  end

  defp validate(expected_transaction_count, transactions) do
    case Enum.count(transactions) do
      ^expected_transaction_count ->
        {:ok, transactions}

      transaction_count ->
        {:error, "got #{transaction_count} transactions, expected #{expected_transaction_count}"}
    end
  end
end
