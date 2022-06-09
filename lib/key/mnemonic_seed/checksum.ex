defmodule BitcoinLib.Key.MnemonicSeed.Checksum do
  @moduledoc """
  Checksum needed to generate a mnemonic seed

  Source: https://raw.githubusercontent.com/bitcoin/bips/master/bip-0039/english.txt
  """

  alias BitcoinLib.Crypto

  @doc """
  Adds checksum at the end of the seed
  """
  @spec compute_and_append_to_seed(Binary.t()) :: Binary.t()
  def compute_and_append_to_seed(binary_seed) do
    nb_checksum_bits =
      binary_seed
      |> byte_size()
      |> div(4)

    checksum = compute(binary_seed, nb_checksum_bits)

    concatenate(binary_seed, checksum, nb_checksum_bits)
  end

  @doc """
  Computes the checksum, which is the first few bits of a SHA256 hash

  ## Examples
    iex> <<27, 172, 62, 126, 195, 84, 6, 180, 26, 1, 13, 250, 0, 254, 239, 132>>
    ...> |> BitcoinLib.Key.MnemonicSeed.Checksum.compute(4)
    2
  """
  @spec compute(Binary.t(), Integer.t()) :: Integer.t()
  def compute(binary_seed, nb_bits_to_keep) do
    binary_seed
    |> compute_sha256()
    |> keep_first_bits(nb_bits_to_keep)
  end

  @doc """
  Computes the checksum, and verify that it matches to the one received

  ## Examples
    iex> <<5, 235, 104, 86, 249, 249, 27, 246, 234, 99, 13, 18, 209, 116, 50, 248, 35>>
    ...> |> BitcoinLib.Key.MnemonicSeed.Checksum.validate_seed()
    true
  """
  @spec validate_seed(Binary.t()) :: true | false
  def validate_seed(binary_seed) do
    nb_of_checksum_bits = number_of_checksum_bits(binary_seed)
    {seed, checksum} = split(binary_seed, nb_of_checksum_bits)

    seed
    |> compute(nb_of_checksum_bits)
    |> Kernel.==(checksum)
  end

  defp compute_sha256(binary_seed) do
    Crypto.sha256_bitstring(binary_seed)
  end

  defp keep_first_bits(full_checksum, nb_bits_to_keep) do
    <<chunk::size(nb_bits_to_keep), _rest::bitstring>> = full_checksum

    chunk
  end

  defp split(binary, nb_of_checksum_bits) do
    binary_size = byte_size(binary) * 8 - nb_of_checksum_bits

    <<integer_seed::size(binary_size), checksum::size(nb_of_checksum_bits)>> = binary

    {
      Binary.from_integer(integer_seed),
      checksum
    }
  end

  defp concatenate(binary_seed, checksum, nb_of_checksum_bits) do
    <<binary_seed::binary, checksum::size(nb_of_checksum_bits)>>
  end

  @spec number_of_checksum_bits(Binary.t()) :: Integer.t()
  def number_of_checksum_bits(binary_seed) do
    bit_size(binary_seed)
    |> div(32)
  end
end
