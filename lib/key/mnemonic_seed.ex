defmodule BitcoinLib.Key.MnemonicSeed do
  alias BitcoinLib.Crypto.BitUtils

  alias BitcoinLib.Key.MnemonicSeed.{Checksum, Wordlist}

  def from_integer(seed) do
    binary_seed = Binary.from_integer(seed)

    size_in_bytes = byte_size(binary_seed)
    nb_checksum_bits = div(size_in_bytes, 4)
    checksum = Checksum.compute(binary_seed, nb_checksum_bits)

    <<binary_seed::binary, checksum::size(nb_checksum_bits)>>
    |> BitUtils.chunks(11)
    |> Enum.map(&(&1 |> pad_leading_zeros |> :binary.decode_unsigned()))
    |> Enum.map(&Wordlist.get(&1))
  end

  defp pad_leading_zeros(bs) when is_bitstring(bs) do
    pad_length = 8 - rem(bit_size(bs), 8)
    <<0::size(pad_length), bs::bitstring>>
  end
end
