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
    with {:ok, entropy} <- Entropy.from_dice_rolls(dice_rolls) do
      {:ok, wordlist_from_entropy(entropy)}
    else
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
    with {:ok, wordlist} <- from_dice_rolls(dice_rolls) do
      wordlist
    else
      {:error, message} -> raise message
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

  @doc """
  Executes the checksum on a seed phrase, making sure it's valid

  ## Examples
      iex> "brick giggle panic mammal document foam gym canvas wheel among room analyst"
      ...> |> BitcoinLib.Key.HD.SeedPhrase.validate()
      true
  """
  @spec validate(binary()) :: boolean()
  def validate(seed_phrase) do
    words =
      seed_phrase
      |> String.split(" ")

    decoded =
      words
      |> Wordlist.get_indices()
      |> combine_indices()

    decoded_size = bit_size(decoded)
    checksum_size = Enum.count(words) |> div(3)
    data_size = decoded_size - checksum_size

    <<data::bitstring-size(data_size), _checksum::size(checksum_size)>> = decoded

    append_checksum(data) == decoded
  end

  @doc """
  Takes two parts of a seed phrase, with a missing word anywhere in between.
  Returns a list of words that would complete it with a valid checksum

  ## Examples
      iex> first_words = "work tenant tourist globe among cattle suggest fever begin boil undo"
      ...> last_words = "work tenant tourist globe among cattle suggest fever begin boil undo slogan"
      ...> BitcoinLib.Key.HD.SeedPhrase.find_possible_missing_words(first_words, last_words)
      ["arrange", "broom", "genius", "hurt", "melody", "repeat", "save", "setup", "strategy"]
  """
  @spec find_possible_missing_words(binary(), binary()) :: list()
  def find_possible_missing_words(first_words, last_words) do
    Wordlist.all()
    |> Enum.map(fn missing_word ->
      valid? =
        "#{first_words |> String.trim()} #{missing_word} #{last_words |> String.trim()}"
        |> String.trim()
        |> validate()

      {missing_word, valid?}
    end)
    |> Enum.filter(fn {_, valid?} ->
      valid?
    end)
    |> Enum.map(fn {valid_word, true} ->
      valid_word
    end)
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

  defp combine_indices(indices) do
    indices
    |> Enum.reduce(
      <<>>,
      fn indice, acc ->
        <<acc::bitstring, indice::11>>
      end
    )
  end

  defp get_word_indices(chunks) do
    chunks
    |> Enum.map(&(&1 |> pad_leading_zeros |> :binary.decode_unsigned()))
  end
end
