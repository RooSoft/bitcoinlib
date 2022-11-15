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
      value: _transaction_count
    } = CompactInteger.extract_from(transactions_data)

    with {:ok, transactions} <- scan(remaining) do
      {:ok, transactions}
    else
      {:error, message} -> {:error, message}
    end
  end

  defp scan(remaininig) do
    with {:ok, transaction} <- Transaction.decode(remaininig) do
      {:ok, [transaction]}
    else
      {:error, message} -> {:error, message}
    end
  end
end
