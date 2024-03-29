defmodule BitcoinLib.Address do
  @moduledoc """
  Bitcoin address management

  Inspired by https://learnmeabitcoin.com/technical/public-key-hash
  """

  require Logger

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.PublicKey
  alias BitcoinLib.Address.{P2PKH, P2SH, Bech32}

  @doc """
  Turns a public key into an address of the specified format

  ## Examples
      iex> %BitcoinLib.Key.PublicKey{
      ...>   key: <<0x0343B337DEC65A47B3362C9620A6E6FF39A1DDFA908ABAB1666C8A30A3F8A7CCCC::264>>
      ...> }
      ...> |> BitcoinLib.Address.from_public_key(:p2wpkh, :mainnet)
      "bc1qa5gyew808tdta3wjh6qh3jvcglukjsnfg0qx4u"
  """
  @spec from_public_key(PublicKey.t(), :p2pkh | :p2sh | :p2wpkh, :mainnet | :testnet) ::
          binary()
  def from_public_key(public_key, script_type, network \\ :mainnet)

  def from_public_key(%PublicKey{} = public_key, :p2pkh, :mainnet),
    do: P2PKH.from_public_key(public_key)

  def from_public_key(%PublicKey{} = public_key, :p2pkh, :testnet),
    do: P2PKH.from_public_key(public_key, :testnet)

  def from_public_key(%PublicKey{} = public_key, :p2sh, :mainnet),
    do: P2SH.from_public_key(public_key)

  def from_public_key(%PublicKey{} = public_key, :p2sh, :testnet),
    do: P2SH.from_public_key(public_key, :testnet)

  def from_public_key(%PublicKey{} = public_key, :p2wpkh, :mainnet),
    do: Bech32.from_public_key(public_key)

  def from_public_key(%PublicKey{} = public_key, :p2wpkh, :testnet),
    do: Bech32.from_public_key(public_key, :testnet)

  @doc """
  Convert public key hash into a P2PKH Bitcoin address.

  Details can be found here: https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses

  ## Examples
      iex> <<0x6ae201797de3fa7d1d95510f50c1a9c50ce4cc36::160>>
      ...> |> BitcoinLib.Address.from_public_key_hash()
      "1Ak9NVPmwCHEpsSWvM6cNRC7dsYniRmwMG"
  """
  @spec from_public_key_hash(binary(), :mainnet | :testnet) :: bitstring()
  def from_public_key_hash(public_key_hash, network \\ :mainnet) do
    P2PKH.from_public_key_hash(public_key_hash, network)
  end

  def from_script_hash(public_key_hash, network \\ :mainnet) do
    P2SH.from_script_hash(public_key_hash, network)
  end

  @doc """
  Applies the address's checksum to make sure it's valid

  ## Examples
      iex> "tb1qxrd42xz49clfrs5mz6thglwlu5vxmdqxsvpnks"
      ...> |> BitcoinLib.Address.valid?()
      true
  """
  @spec valid?(binary()) :: boolean()

  def valid?("1" <> _ = address) do
    P2PKH.valid?(address)
  end

  def valid?("m" <> _ = address) do
    P2PKH.valid?(address)
  end

  def valid?("2" <> _ = address) do
    P2SH.valid?(address)
  end

  def valid?("3" <> _ = address) do
    P2SH.valid?(address)
  end

  def valid?("tb1" <> _ = address) do
    Bech32.valid?(address)
  end

  def valid?("bc1" <> _ = address) do
    Bech32.valid?(address)
  end

  def valid?(address) do
    Logger.error("#{address} is of an unknown address type")
  end

  @doc """
  Extracts the public key hash from an address, and make sure the checkum is ok

  ## Examples
      iex> address = "tb1qxrd42xz49clfrs5mz6thglwlu5vxmdqxsvpnks"
      ...> BitcoinLib.Address.destructure(address)
      {:ok, <<0x30db5518552e3e91c29b1697747ddfe5186db406::160>>, :p2wpkh, :testnet}

      iex> address = "mwYKDe7uJcgqyVHJAPURddeZvM5zBVQj5L"
      ...> BitcoinLib.Address.destructure(address)
      {:ok, <<0xafc3e518577316386188af748a816cd14ce333f2::160>>, :p2pkh, :testnet}
  """
  @spec destructure(binary()) ::
          {:ok, <<_::272>> | <<_::160>>, :p2pkh | :p2sh | :p2wpkh, :mainnet | :testnet}
          | {:error, binary()}

  def destructure("bc1" <> _ = bech32_address), do: Bech32.destructure(bech32_address)
  def destructure("tb1" <> _ = bech32_address), do: Bech32.destructure(bech32_address)

  def destructure(address) do
    try do
      case Base58.decode(address) do
        <<prefix::8, public_key_hash::bitstring-160, checksum::bitstring-32>> ->
          case get_address_type_from_prefix(prefix) do
            {address_type, network} ->
              case test_checksum(prefix, public_key_hash, checksum) do
                {:ok} -> {:ok, public_key_hash, address_type, network}
                {:error, message} -> {:error, message}
              end

            :unknown ->
              {:error, "unknown address format"}
          end

        _ ->
          {:error, "unknown address format"}
      end
    rescue
      _ ->
        {:error, "address is not base58 compatible"}
    end
  end

  @spec test_checksum(integer(), bitstring(), bitstring()) :: {:ok} | {:error, binary()}
  defp test_checksum(prefix, public_key_hash, original_checksum) do
    calculated_checksum =
      <<prefix::8, public_key_hash::bitstring-160>>
      |> Crypto.checksum()

    case calculated_checksum do
      ^original_checksum -> {:ok}
      _ -> {:error, "checksums don't match"}
    end
  end

  # example 17VZNX1SN5NtKa8UQFxwQbFeFc3iqRYhem
  defp get_address_type_from_prefix(0), do: {:p2pkh, :mainnet}

  # example 3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX
  defp get_address_type_from_prefix(5), do: {:p2sh, :mainnet}

  # example mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn
  defp get_address_type_from_prefix(111), do: {:p2pkh, :testnet}

  # example 2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc
  defp get_address_type_from_prefix(196), do: {:p2sh, :testnet}

  defp get_address_type_from_prefix(_), do: :unknown
end
