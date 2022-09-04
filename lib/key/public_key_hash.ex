defmodule BitcoinLib.Key.PublicKeyHash do
  @moduledoc """
  Bitcoin Public Key Hash module
  """

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.PublicKey

  @doc """
  Extract a public key hash from a bitcoin public key

  Inspired by https://learnmeabitcoin.com/technical/public-key-hash

  ## Examples
    iex> %BitcoinLib.Key.PublicKey{
    ...>   key: <<0x02b4632d08485ff1df2db55b9dafd23347d1c47a457072a1e87be26896549a8737::264>>
    ...> }
    ...> |> BitcoinLib.Key.PublicKeyHash.from_public_key()
    <<0x93ce48570b55c42c2af816aeaba06cfee1224fae::160>>
  """
  @spec from_public_key(%PublicKey{}) :: bitstring()
  def from_public_key(%PublicKey{key: key}) do
    key
    |> Crypto.hash160()
  end

  @spec from_address(binary()) :: bitstring()
  def from_address(address) do
    <<prefix::8, public_key_hash::bitstring-160, checksum::bitstring-32>> =
      address
      |> Base58.decode()

    case test_checksum(prefix, public_key_hash, checksum) do
      {:ok} -> {:ok, public_key_hash}
      {:error, message} -> {:error, message}
    end
  end

  @spec test_checksum(integer(), bitstring(), integer()) :: {:ok} | {:error, binary()}
  defp test_checksum(prefix, public_key_hash, original_checksum) do
    calculated_checksum =
      <<prefix::8, public_key_hash::bitstring-160>>
      |> Crypto.checksum()

    case calculated_checksum do
      ^original_checksum -> {:ok}
      _ -> {:error, "checksums don't match"}
    end
  end
end
