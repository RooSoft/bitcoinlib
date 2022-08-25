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
    |> double_sha256()
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
    ...> |> BitcoinLib.Crypto.sha1()
    <<28, 144, 213, 16, 97, 233, 15, 148, 131, 216, 156, 178, 53, 37, 165, 241, 222, 50, 60, 216>>
  """
  @spec sha1(String.t()) :: bitstring()
  def sha1(bin) when is_bitstring(bin), do: :crypto.hash(:sha, bin)

  @doc """
  Computes [SHA256](https://en.wikipedia.org/wiki/SHA-2) on a binary and returns it as a binary

  ## Examples

    iex> "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"
    ...> |> BitcoinLib.Crypto.sha256()
    <<171, 106, 143, 29, 158, 43, 3, 51, 223, 248, 227, 112, 237, 111, 223, 226, 11, 46, 128, 8, 224, 69, 239, 179, 251, 50, 152, 194, 47, 117, 105, 218>>
  """
  @spec sha256(String.t()) :: bitstring()
  def sha256(bin) when is_bitstring(bin) do
    :crypto.hash(:sha256, bin)
  end

  @doc """
  Computes [SHA256](https://en.wikipedia.org/wiki/SHA-2) twice on a binary and returns it as a binary

  ## Examples

    iex> "6c7ab2f961a1bc3f13cdc08dc41c3f439adebd549a8ef1c089e81a5907376107"
    ...> |> BitcoinLib.Crypto.double_sha256()
    <<222, 67, 52, 47, 110, 139, 204, 52, 217, 95, 54, 228, 225, 184, 234, 185, 87, 160, 206, 47, 243, 176, 225, 131, 20, 45, 145, 168, 113, 23, 15, 43>>
  """
  @spec double_sha256(String.t()) :: bitstring()
  def double_sha256(bin) when is_bitstring(bin) do
    bin
    |> sha256
    |> sha256
  end

  @doc """
  Computes [HMAC](https://en.wikipedia.org/wiki/HMAC) on a binary and returns it as a binary

  ## Examples

    iex> seed = "b1680c7a6ea6ed5ac9bf3bc3b43869a4c77098e60195bae51a94159333820e125c3409b8c8d74b4489f28ce71b06799b1126c1d9620767c2dadf642cf787cf36"
    ...> key = "Bitcoin seed"
    ...> BitcoinLib.Crypto.hmac(seed, key)
    <<31, 34, 233, 148, 64, 182, 33, 228, 126, 116, 167, 121, 206, 64, 99, 196, 151,
    132, 106, 177, 24, 250, 37, 49, 164, 150, 17, 212, 61, 202, 87, 135, 234, 45,
    15, 185, 89, 55, 20, 76, 79, 227, 115, 11, 110, 101, 104, 149, 208, 227, 13,
    239, 163, 18, 177, 100, 114, 124, 164, 205, 211, 83, 11, 67>>
  """
  @spec hmac(String.t(), String.t()) :: bitstring()
  def hmac(bin, key) when is_bitstring(bin) do
    :crypto.mac(:hmac, :sha512, key, bin)
  end

  @doc """
  Computes a hash160 of a bitstring, which is the ripemd160 of a sha256

  ## Examples
    iex> <<128, 0, 0, 44>>
    ...> |> BitcoinLib.Crypto.hash160()
    <<251, 126, 153, 20, 166, 224, 56, 154, 55, 180, 46, 3, 58, 245, 19, 162, 196, 12, 64, 2>>
  """
  @spec hash160(bitstring()) :: bitstring()
  def hash160(data) do
    data
    |> sha256()
    |> ripemd160_bitstring()
  end

  @doc """
  Computes a point on the [ellpitic curve](https://en.bitcoin.it/wiki/Secp256k1) on a binary and returns it as a binary

  ## Examples

    iex> value = <<0xD6, 0xEA, 0xD2, 0x33, 0xE0, 0x6C, 0x6, 0x85, 0x85, 0x97, 0x6B, 0x5C, 0x83,
    ...>   0x73, 0x86, 0x1D, 0x77, 0xE7, 0xF0, 0x30, 0xEC, 0x45, 0x2E, 0x65, 0xEE, 0x81,
    ...>   0xC8, 0x5F, 0xA6, 0x90, 0x69, 0x70>>
    ...> BitcoinLib.Crypto.secp256k1(value)
    <<4, 112, 45, 237, 28, 202, 152, 22, 250, 26, 148, 120, 127, 252, 111, 58, 206,
      98, 205, 59, 99, 22, 79, 118, 210, 39, 208, 147, 90, 51, 238, 72, 195, 86,
      255, 200, 70, 166, 27, 12, 103, 60, 186, 204, 246, 36, 62, 191, 55, 255, 91,
      162, 76, 111, 113, 88, 193, 139, 127, 168, 9, 13, 240, 215, 228>>
  """
  @spec secp256k1(bitstring()) :: bitstring()
  def secp256k1(bin) when is_bitstring(bin) do
    :crypto.generate_key(:ecdh, :secp256k1, bin)
    |> elem(0)
  end
end
