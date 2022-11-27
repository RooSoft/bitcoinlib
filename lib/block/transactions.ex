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

  defp scan(expected_transaction_count, remaining) do
    with {:ok, transactions} <- extract_transactions(remaining) do
      validate(expected_transaction_count, transactions)
    else
      {:error, message} -> {:error, message}
    end
  end

  defp extract_transactions(remaining) do
    with {:ok, coinbase, remaining} <- extract_coinbase(remaining) do
      extract_next_transaction([coinbase], remaining)
    else
      {:error, message} -> {:error, message}
    end
  end

  defp extract_coinbase(remaining) do
    Transaction.decode(remaining, true)
  end

  defp extract_next_transaction(transactions, <<>>), do: {:ok, transactions |> Enum.reverse()}

  defp extract_next_transaction(transactions, remaining) do
    with {:ok, transaction, remaining} <- Transaction.decode(remaining, false) do
      extract_next_transaction([transaction | transactions], remaining)
    else
      {:error, message} ->
        transaction_count = Enum.count(transactions)
        {:error, "#{transaction_count} transactions in the block, #{message}"}
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
