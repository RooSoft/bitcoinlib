defmodule BitcoinLib.Key.MnemonicSeed.Checksum do
  @moduledoc """
  Checksum needed to generate a mnemonic seed

  Source: https://raw.githubusercontent.com/bitcoin/bips/master/bip-0039/english.txt
  """

  alias BitcoinLib.Crypto

  @doc """
  Computes the checksum, which is the first few bits of a SHA256 hash

  ## Examples
    iex> 36_783_498_498_455_780_461_879_399_537_283_362_692
    ...> |> Binary.from_integer()
    ...> |> BitcoinLib.Key.MnemonicSeed.Checksum.compute(4)
    2
  """
  @spec compute(Integer.t(), Integer.t()) :: Integer.t()
  def compute(binary_seed, nb_bits_to_keep) do
    binary_seed
    |> compute_sha256()
    |> keep_first_bits(nb_bits_to_keep)
  end

  defp compute_sha256(binary_seed) do
    Crypto.sha256_bitstring(binary_seed)
  end

  defp keep_first_bits(full_checksum, nb_bits_to_keep) do
    <<chunk::size(nb_bits_to_keep), _rest::bitstring>> = full_checksum

    chunk
  end
end
