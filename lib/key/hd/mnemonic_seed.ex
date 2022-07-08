defmodule BitcoinLib.Key.HD.MnemonicSeed do
  @moduledoc """
  Compute a mnemonic seed from a private key
  """

  @pbkdf2_opts rounds: 2048, digest: :sha512, length: 64, format: :hex

  alias BitcoinLib.Crypto.BitUtils

  alias BitcoinLib.Key.HD.MnemonicSeed.{Checksum, Wordlist}

  @doc """
  Convert a random entropy number into a mnemonic seed

  ## Examples
    iex> 101_750_443_022_601_924_635_824_320_539_097_414_732
    ...> |> BitcoinLib.Key.HD.MnemonicSeed.wordlist_from_entropy()
    "erode gloom apart system broom lemon dismiss post artist slot humor occur"
  """
  @spec wordlist_from_entropy(integer()) :: binary()
  def wordlist_from_entropy(entropy) do
    entropy
    |> Binary.from_integer()
    |> append_checksum
    |> split_indices
    |> get_word_indices
    |> Wordlist.get_words()
    |> Enum.join(" ")
  end

  @doc """
  Convert a mnemonic phrase into a seed, with a optional passphrase

  ## Examples
    iex> "brick giggle panic mammal document foam gym canvas wheel among room analyst"
    ...> |> BitcoinLib.Key.HD.MnemonicSeed.to_seed()
    "7e4803bd0278e223532f5833d81605bedc5e16f39c49bdfff322ca83d444892ddb091969761ea406bee99d6ab613fad6a99a6d4beba66897b252f00c9dd7b364"
  """
  @spec to_seed(binary(), binary()) :: binary()
  def to_seed(mnemonic_phrase, passphrase \\ "") do
    Pbkdf2.Base.hash_password(mnemonic_phrase, "mnemonic#{passphrase}", @pbkdf2_opts)
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
