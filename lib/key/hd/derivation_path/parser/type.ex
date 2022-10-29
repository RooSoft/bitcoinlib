defmodule BitcoinLib.Key.HD.DerivationPath.Parser.Type do
  @moduledoc """
  Extracts the first value of a derivation path, which is public or private.

  This is a hardened value.

  See: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
  """

  @private "m"
  @private_atom :private

  @public "M"
  @public_atom :public

  @doc """
  Converts a list of path levels managed up until the type value, extracts
  the type and returns the remaining levels

  ## Examples
      iex> ["m", "0", "1", "2", "3", "4"]
      ...> |> BitcoinLib.Key.HD.DerivationPath.Parser.Type.extract()
      {:ok, :private, ["0", "1", "2", "3", "4"]}
  """
  @spec extract(list()) :: {:ok, atom(), list()} | {:ok, nil, []} | {:error, binary()}
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
  defp convert(purpose, _rest), do: {:error, "#{purpose} is not a valid type"}
end
