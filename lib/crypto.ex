defmodule BitcoinLib.Crypto do
  @moduledoc """
  Cryptography functions
  """

  @doc """
  Takes any hexadecimal value as a string and creates a double-sha256,
  keeping only the first 4 bytes

  ## Examples

    iex> "806c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a590737610701"
    ...> |> BitcoinLib.Crypto.checksum()
    "b56c36b1"
  """
  def checksum(str) when is_binary(str) do
    str
    |> String.upcase()
    |> Base.decode16!()
    |> checksum_bitstring
    |> Base.encode16()
    |> String.downcase()
  end

  def ripemd160(str) when is_binary(str) do
    str
    |> ripemd160_bitstring()
    |> Base.encode16()
    |> String.downcase()
  end

  def sha1(str) when is_binary(str) do
    str
    |> sha1_bitstring()
    |> Base.encode16()
  end

  def sha256(str) when is_binary(str) do
    str
    |> sha256_bitstring()
    |> Base.encode16()
    |> String.downcase()
  end

  def double_sha256(str) when is_binary(str) do
    str
    |> Base.decode16!()
    |> double_sha256_bitstring()
    |> Base.encode16()
  end

  @doc """
  Takes any binary and creates a double-sha256, keeping only the first 4 bytes

  ## Examples

    iex> value = <<128, 108, 122, 178, 249, 97, 161, 188, 63, 19, 205, 192, 141, 196, 28, 63, 67>>
    ...> value = value <> <<154, 222, 189, 84, 154, 142, 241, 192, 137, 232, 26, 89, 7, 55, 97, 7, 1>>
    ...> value |> BitcoinLib.Crypto.checksum_bitstring()
    <<181, 108, 54, 177>>
  """
  def checksum_bitstring(bin) when is_bitstring(bin) do
    bin
    |> double_sha256_bitstring()
    |> Binary.take(4)
  end

  def ripemd160_bitstring(bin) when is_bitstring(bin), do: :crypto.hash(:ripemd160, bin)
  def sha1_bitstring(bin) when is_bitstring(bin), do: :crypto.hash(:sha, bin)

  def sha256_bitstring(bin) when is_bitstring(bin) do
    :crypto.hash(:sha256, bin)
  end

  def double_sha256_bitstring(bin) when is_bitstring(bin) do
    hash1 = :crypto.hash(:sha256, bin)
    :crypto.hash(:sha256, hash1)
  end
end
