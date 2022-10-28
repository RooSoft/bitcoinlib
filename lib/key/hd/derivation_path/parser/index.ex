defmodule BitcoinLib.Key.HD.DerivationPath.Parser.Index do
  # https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#index

  def extract([]), do: {:ok, nil, []}

  def extract([index | rest]) do
    index
    |> Integer.parse()
    |> convert(rest)
  end

  defp convert({index, ""}, rest), do: {:ok, index, rest}
  defp convert({_index, _remainder}, _rest), do: {:error, "index should be an integer"}
  defp convert(:error, _rest), do: {:error, "index should be a valid integer"}
end
