defmodule BitcoinLib.Key.MnemonicSeed do
  @moduledoc """
  Compute a mnemonic seed from a private key
  """

  alias BitcoinLib.Crypto.BitUtils

  alias BitcoinLib.Key.MnemonicSeed.{Checksum, Wordlist}

  @doc """
  Convert an integer into a mnemonic seed

  ## Examples
    iex> 101_750_443_022_601_924_635_824_320_539_097_414_732
    ...> |> BitcoinLib.Key.MnemonicSeed.wordlist_from_integer()
    ...> |> Enum.join(" ")
    "erode gloom apart system broom lemon dismiss post artist slot humor occur"
  """
  @spec wordlist_from_integer(Integer.t()) :: list(String.t())
  def wordlist_from_integer(seed) do
    seed
    |> append_checksum
    |> BitUtils.chunks(11)
    |> Enum.map(&(&1 |> pad_leading_zeros |> :binary.decode_unsigned()))
    |> Enum.map(&Wordlist.get(&1))
  end

  defp append_checksum(seed) do
    binary_seed = Binary.from_integer(seed)

    nb_checksum_bits =
      binary_seed
      |> byte_size()
      |> div(4)

    checksum = Checksum.compute(binary_seed, nb_checksum_bits)

    concatenate(binary_seed, checksum, nb_checksum_bits)
  end

  defp concatenate(binary_seed, checksum, nb_of_checksum_bits) do
    <<binary_seed::binary, checksum::size(nb_of_checksum_bits)>>
  end

  defp pad_leading_zeros(bs) when is_bitstring(bs) do
    pad_length = 8 - rem(bit_size(bs), 8)
    <<0::size(pad_length), bs::bitstring>>
  end
end
