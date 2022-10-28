defmodule BitcoinLib.Key.HD.DerivationPath.Parser.Type do
  # https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
  @private "m"
  @private_atom :private

  @public "M"
  @public_atom :public

  def extract([]), do: {:ok, nil, []}

  def extract([type | rest]) do
    type
    |> String.trim()
    |> convert(rest)
  end

  def get_atom(@private), do: @private_atom
  def get_atom(@public), do: @public_atom
  def get_atom(unknown), do: {:error, "#{unknown} is an invalid key type"}

  defp convert(@private, rest), do: {:ok, @private_atom, rest}
  defp convert(@public, rest), do: {:ok, @public_atom, rest}
  defp convert(purpose, _rest), do: {:error, "#{purpose} is not a valid purpose"}
end
