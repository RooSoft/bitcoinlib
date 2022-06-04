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
  @spec checksum(String.t()) :: String.t()
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
  @spec ripemd160(String.t()) :: String.t()
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
  @spec sha1(String.t()) :: String.t()
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
  @spec sha256(String.t()) :: String.t()
  def sha256(str) when is_binary(str) do
    str
    |> sha256_bitstring()
    |> Base.encode16(case: :lower)
  end

  @doc """
  Computes [SHA256](https://en.wikipedia.org/wiki/SHA-2) twice in a row on an arbitrary string

  ## Examples

    iex> "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"
    ...> |> BitcoinLib.Crypto.double_sha256()
    "de43342f6e8bcc34d95f36e4e1b8eab957a0ce2ff3b0e183142d91a871170f2b"
  """
  @spec double_sha256(String.t()) :: String.t()
  def double_sha256(str) when is_binary(str) do
    str
    |> double_sha256_bitstring()
    |> Base.encode16(case: :lower)
  end

  @doc """
  Computes [HMAC](https://en.wikipedia.org/wiki/HMAC) on an arbitrary string

  ## Examples

    iex> seed = "b1680c7a6ea6ed5ac9bf3bc3b43869a4c77098e60195bae51a94159333820e125c3409b8c8d74b4489f28ce71b06799b1126c1d9620767c2dadf642cf787cf36"
    ...> key = "Bitcoin seed"
    ...> BitcoinLib.Crypto.hmac(seed, key)
    "1f22e99440b621e47e74a779ce4063c497846ab118fa2531a49611d43dca5787ea2d0fb95937144c4fe3730b6e656895d0e30defa312b164727ca4cdd3530b43"
  """
  @spec hmac(String.t(), String.t()) :: String.t()
  def hmac(str, key) when is_binary(str) do
    hmac_bitstring(str, key)
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
  @spec checksum_bitstring(bitstring()) :: bitstring()
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
  @spec ripemd160_bitstring(String.t()) :: bitstring()
  def ripemd160_bitstring(bin) when is_bitstring(bin), do: :crypto.hash(:ripemd160, bin)

  @doc """
  Computes [SHA1](https://en.wikipedia.org/wiki/SHA-1) on a binary and returns it as a binary

  ## Examples

    iex> "806c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a590737610701"
    ...> |> BitcoinLib.Crypto.sha1_bitstring()
    <<28, 144, 213, 16, 97, 233, 15, 148, 131, 216, 156, 178, 53, 37, 165, 241, 222, 50, 60, 216>>
  """
  @spec sha1_bitstring(String.t()) :: bitstring()
  def sha1_bitstring(bin) when is_bitstring(bin), do: :crypto.hash(:sha, bin)

  @doc """
  Computes [SHA256](https://en.wikipedia.org/wiki/SHA-2) on a binary and returns it as a binary

  ## Examples

    iex> "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"
    ...> |> BitcoinLib.Crypto.sha256_bitstring()
    <<171, 106, 143, 29, 158, 43, 3, 51, 223, 248, 227, 112, 237, 111, 223, 226, 11, 46, 128, 8, 224, 69, 239, 179, 251, 50, 152, 194, 47, 117, 105, 218>>
  """
  @spec sha256_bitstring(String.t()) :: bitstring()
  def sha256_bitstring(bin) when is_bitstring(bin) do
    :crypto.hash(:sha256, bin)
  end

  @doc """
  Computes [SHA256](https://en.wikipedia.org/wiki/SHA-2) twice on a binary and returns it as a binary

  ## Examples

    iex> "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"
    ...> |> BitcoinLib.Crypto.double_sha256_bitstring()
    <<222, 67, 52, 47, 110, 139, 204, 52, 217, 95, 54, 228, 225, 184, 234, 185, 87, 160, 206, 47, 243, 176, 225, 131, 20, 45, 145, 168, 113, 23, 15, 43>>
  """
  @spec double_sha256_bitstring(String.t()) :: bitstring()
  def double_sha256_bitstring(bin) when is_bitstring(bin) do
    bin
    |> sha256_bitstring
    |> sha256_bitstring
  end

  @doc """
  Computes [HMAC](https://en.wikipedia.org/wiki/HMAC) on a binary and returns it as a binary

  ## Examples

    iex> seed = "b1680c7a6ea6ed5ac9bf3bc3b43869a4c77098e60195bae51a94159333820e125c3409b8c8d74b4489f28ce71b06799b1126c1d9620767c2dadf642cf787cf36"
    ...> key = "Bitcoin seed"
    ...> BitcoinLib.Crypto.hmac_bitstring(seed, key)
    <<31, 34, 233, 148, 64, 182, 33, 228, 126, 116, 167, 121, 206, 64, 99, 196, 151,
    132, 106, 177, 24, 250, 37, 49, 164, 150, 17, 212, 61, 202, 87, 135, 234, 45,
    15, 185, 89, 55, 20, 76, 79, 227, 115, 11, 110, 101, 104, 149, 208, 227, 13,
    239, 163, 18, 177, 100, 114, 124, 164, 205, 211, 83, 11, 67>>
  """
  @spec hmac_bitstring(String.t(), String.t()) :: bitstring()
  def hmac_bitstring(bin, key) when is_bitstring(bin) do
    :crypto.mac(:hmac, :sha512, key, bin)
  end
end
