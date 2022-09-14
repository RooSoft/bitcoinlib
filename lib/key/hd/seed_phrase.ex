defmodule BitcoinLib.Key.HD.SeedPhrase do
  @moduledoc """
  A seed phrase can generate a private key. It is a human friendly way to store
  private keys for disaster recovery.
  """

  @pbkdf2_opts rounds: 2048, digest: :sha512, length: 64, format: :hex

  alias BitcoinLib.Crypto.BitUtils

  alias BitcoinLib.Key.HD.SeedPhrase.{Checksum, Wordlist}
  alias BitcoinLib.Key.HD.Entropy

  @doc """
  Create a seed phrase out of entropy

  ## Examples
    iex> 101_750_443_022_601_924_635_824_320_539_097_414_732
    ...> |> BitcoinLib.Key.HD.SeedPhrase.wordlist_from_entropy()
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
  Convert a set of 50 or 99 dice rolls into a 12 or 24 word list

  ## Examples
    iex> "12345612345612345612345612345612345612345612345612"
    ...> |> BitcoinLib.Key.HD.SeedPhrase.from_dice_rolls()
    {:ok, "blue involve cook print twist crystal razor february caution private slim medal"}
  """
  @spec from_dice_rolls(binary()) :: {:ok, binary()} | {:error, binary()}
  def from_dice_rolls(dice_rolls) do
    case Entropy.from_dice_rolls(dice_rolls) do
      {:ok, entropy} -> {:ok, wordlist_from_entropy(entropy)}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Convert a set of 50 or 99 dice rolls into a 12 or 24 word list

  ## Examples
    iex> "12345612345612345612345612345612345612345612345612"
    ...> |> BitcoinLib.Key.HD.SeedPhrase.from_dice_rolls!()
    "blue involve cook print twist crystal razor february caution private slim medal"
  """
  @spec from_dice_rolls!(binary()) :: binary()
  def from_dice_rolls!(dice_rolls) do
    case from_dice_rolls(dice_rolls) do
      {:ok, wordlist} -> wordlist
      {:error, message} -> throw(message)
    end
  end

  @doc """
  Convert a seed phrase into a seed, with a optional passphrase

  See https://learnmeabitcoin.com/technical/mnemonic#mnemonic-to-seed

  ## Examples
    iex> "brick giggle panic mammal document foam gym canvas wheel among room analyst"
    ...> |> BitcoinLib.Key.HD.SeedPhrase.to_seed()
    "7e4803bd0278e223532f5833d81605bedc5e16f39c49bdfff322ca83d444892ddb091969761ea406bee99d6ab613fad6a99a6d4beba66897b252f00c9dd7b364"
  """
  @spec to_seed(binary(), binary()) :: binary()
  def to_seed(seed_phrase, passphrase \\ "") do
    Pbkdf2.Base.hash_password(seed_phrase, "mnemonic#{passphrase}", @pbkdf2_opts)
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
