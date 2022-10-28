defmodule BitcoinLib.Key.HD.DerivationPath.Parser.Account do
  # https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#account

  def extract([]), do: {:ok, nil, []}

  def extract([account | rest]) do
    with account <- String.trim(account),
         {:ok, account} <- extract_hardened_value(account) do
      account
      |> Integer.parse()
      |> convert(rest)
    else
      nil -> {:ok, nil}
      {:error, message} -> {:error, message}
    end
  end

  defp extract_hardened_value(""), do: {:ok, nil}

  defp extract_hardened_value(hardened_value) do
    {account, hardened} = String.split_at(hardened_value, -1)

    case hardened do
      "'" -> {:ok, account}
      _ -> {:error, "account number must be a hardened value"}
    end
  end

  defp convert({account, ""}, rest), do: {:ok, account, rest}
  defp convert({_account, _remainder}, _rest), do: {:error, "account should be an integer"}
  defp convert(:error, _rest), do: {:error, "account should be a valid integer"}
end
