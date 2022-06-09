defmodule BitcoinLib.Key.MnemonicSeed do
  @moduledoc """
  Compute a mnemonic seed from a private key
  """

  alias BitcoinLib.Crypto.BitUtils

  alias BitcoinLib.Key.MnemonicSeed.{Checksum, Wordlist}

  @doc """
  Convert a random integer into a mnemonic seed

  ## Examples
    iex> 101_750_443_022_601_924_635_824_320_539_097_414_732
    ...> |> BitcoinLib.Key.MnemonicSeed.wordlist_from_entropy()
    ...> |> Enum.join(" ")
    "erode gloom apart system broom lemon dismiss post artist slot humor occur"
  """
  @spec wordlist_from_entropy(Integer.t()) :: list(String.t())
  def wordlist_from_entropy(seed) do
    seed
    |> Binary.from_integer()
    |> append_checksum
    |> split_indices
    |> get_word_indices
    |> Wordlist.get_words()
  end

  defp append_checksum(binary_seed) do
    binary_seed
    |> Checksum.compute_and_append_to_seed()
  end

  defp pad_leading_zeros(bs) when is_bitstring(bs) do
    pad_length = 8 - rem(bit_size(bs), 8)
    <<0::size(pad_length), bs::bitstring>>
  end

  defp split_indices(seed_with_checksum) do
    seed_with_checksum
    |> BitUtils.split(11)
  end

  defp get_word_indices(chunks) do
    chunks
    |> Enum.map(&(&1 |> pad_leading_zeros |> :binary.decode_unsigned()))
  end
end
