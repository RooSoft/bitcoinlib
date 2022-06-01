defmodule BitcoinLib.Crypto do
  @moduledoc """
  Cryptography functions
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
