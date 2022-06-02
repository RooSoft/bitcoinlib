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
    |> Base.encode16(case: :lower)
  end

  @doc """
  Computes [RIPEMD160](https://en.wikipedia.org/wiki/RIPEMD) on an arbitrary string

  ## Examples

    iex> "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"
    ...> |> BitcoinLib.Crypto.ripemd160()
    "f23d97252131c60666708e4ae2c59fed1349f439"
  """
  def ripemd160(str) when is_binary(str) do
    str
    |> ripemd160_bitstring()
    |> Base.encode16(case: :lower)
  end

  @doc """
  Computes [SHA1](https://en.wikipedia.org/wiki/SHA-1) on an arbitrary string

  ## Examples

    iex> "806c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a590737610701"
    ...> |> BitcoinLib.Crypto.sha1()
    "1c90d51061e90f9483d89cb23525a5f1de323cd8"
  """
  def sha1(str) when is_binary(str) do
    str
    |> sha1_bitstring()
    |> Base.encode16(case: :lower)
  end

  @doc """
  Computes [SHA256](https://en.wikipedia.org/wiki/SHA-2) on an arbitrary string

  ## Examples

    iex> "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"
    ...> |> BitcoinLib.Crypto.sha256()
    "ab6a8f1d9e2b0333dff8e370ed6fdfe20b2e8008e045efb3fb3298c22f7569da"
  """
  def sha256(str) when is_binary(str) do
    str
    |> sha256_bitstring()
    |> Base.encode16(case: :lower)
  end

  def double_sha256(str) when is_binary(str) do
    str
    |> Base.decode16!()
    |> double_sha256_bitstring()
    |> Base.encode16(case: :lower)
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

  @doc """
  Computes [RIPEMD160](https://en.wikipedia.org/wiki/RIPEMD) on a binary and returns it as a binary

  ## Examples

    iex> "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"
    ...> |> BitcoinLib.Crypto.ripemd160_bitstring()
    <<242, 61, 151, 37, 33, 49, 198, 6, 102, 112, 142, 74, 226, 197, 159, 237, 19, 73, 244, 57>>
  """
  def ripemd160_bitstring(bin) when is_bitstring(bin), do: :crypto.hash(:ripemd160, bin)

  @doc """
  Computes [SHA1](https://en.wikipedia.org/wiki/SHA-1) on a binary and returns it as a binary

  ## Examples

    iex> "806c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a590737610701"
    ...> |> BitcoinLib.Crypto.sha1_bitstring()
    <<28, 144, 213, 16, 97, 233, 15, 148, 131, 216, 156, 178, 53, 37, 165, 241, 222, 50, 60, 216>>
  """
  def sha1_bitstring(bin) when is_bitstring(bin), do: :crypto.hash(:sha, bin)

  @doc """
  Computes [SHA256](https://en.wikipedia.org/wiki/SHA-2) on a binary and returns it as a binary

  ## Examples

    iex> "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"
    ...> |> BitcoinLib.Crypto.sha256_bitstring()
    <<171, 106, 143, 29, 158, 43, 3, 51, 223, 248, 227, 112, 237, 111, 223, 226, 11, 46, 128, 8, 224, 69, 239, 179, 251, 50, 152, 194, 47, 117, 105, 218>>
  """
  def sha256_bitstring(bin) when is_bitstring(bin) do
    :crypto.hash(:sha256, bin)
  end

  def double_sha256_bitstring(bin) when is_bitstring(bin) do
    hash1 = :crypto.hash(:sha256, bin)
    :crypto.hash(:sha256, hash1)
  end
end
