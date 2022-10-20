defmodule BitcoinLib.Key.HD.DerivationPath.Parser.Purpose do
  # https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#purpose
  @bip44_purpose 44
  @bip44_atom :bip44

  # https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki#public-key-derivation
  @bip49_purpose 49
  @bip49_atom :bip49

  # https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#public-key-derivation
  @bip84_purpose 84
  @bip84_atom :bip84

  @invalid_atom :invalid

  @doc """
  Converts an bip integer into an atom representing the purpose

  ## Examples
      iex> BitcoinLib.Key.HD.DerivationPath.Parser.Purpose.parse(44)
      :bip44
  """
  @spec parse(integer()) :: :bip44 | :bip49 | :bip84 | :invalid
  def parse(purpose) when is_integer(purpose) do
    case purpose do
      @bip44_purpose -> @bip44_atom
      @bip49_purpose -> @bip49_atom
      @bip84_purpose -> @bip84_atom
      _ -> @invalid_atom
    end
  end
end
