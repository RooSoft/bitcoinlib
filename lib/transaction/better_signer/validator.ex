defmodule BitcoinLib.Transaction.BetterSigner.Validator do
  def validate(transaction, private_keys) do
    if validate_key_count(transaction, private_keys) do
      :ok
    else
      {:error,
       "should provide #{Enum.count(transaction.inputs)} private keys, got #{Enum.count(private_keys)}"}
    end
  end

  defp validate_key_count(transaction, private_keys),
    do: Enum.count(transaction.inputs) == Enum.count(private_keys)
end
