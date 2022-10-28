defmodule BitcoinLib.Address.Bech32 do
  require Logger

  @moduledoc """
  Implementation of Bech32 addresses

  BIP173: https://en.bitcoin.it/wiki/BIP_0173

  Sources:
  - https://en.bitcoin.it/wiki/Bech32
  - https://bitcointalk.org/index.php?topic=4992632.0
  """

  ## Had to disable warning for these functions because of a problem
  ## arising from the use of SegwitAddr.decode/1. Much time has been
  ## spent to understand why, but these below instructions had been
  ## added in the spirit of moving forward, as the function was operating
  ## perfectly despite Dialyzer thinking otherwise.
  @dialyzer {:nowarn_function, destructure: 1}
  @dialyzer {:nowarn_function, classify: 2}

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.PublicKey

  @doc """
  Creates a Bech32 address, which is starting by bc1, out of an Extended Public Key

  ## Examples
      iex> %BitcoinLib.Key.PublicKey{
      ...>  key: <<0x0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798::264>>,
      ...>  chain_code: 0
      ...> } |> BitcoinLib.Address.Bech32.from_public_key()
      "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4"
  """
  @spec from_public_key(%PublicKey{}, :mainnet | :testnet) :: binary()
  def from_public_key(%PublicKey{key: key}, network \\ :mainnet) do
    key
    |> Crypto.hash160()
    |> from_public_key_hash(network)
  end

  @doc """
  Creates a Bech32 address, which is starting by bc1, out of a 160 bits public key hash

  ## Examples
      iex> <<0x751e76e8199196d454941c45d1b3a323f1433bd6::160>>
      ...> |> BitcoinLib.Address.Bech32.from_public_key_hash()
      "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4"
  """
  @spec from_public_key_hash(<<_::160>>, :mainnet | :testnet) :: binary()
  def from_public_key_hash(public_key_hash = <<_::160>>, network \\ :mainnet) do
    hrp = get_hrp(network)

    SegwitAddr.encode(hrp, 0, public_key_hash |> :binary.bin_to_list())
  end

  @doc """
  Creates either of these Bech32 native address types

  - pay to witness public key hash address out of a 20 bytes pub key
  - pay to witness script hash address out of a 32 bytes script hash

  ## Examples
      iex> <<0x001400d21980ae3e9641db6897dad7b8b69b07d9aaac::176>>
      ...> |> BitcoinLib.Address.Bech32.from_script_hash(:testnet)
      "tb1qqrfpnq9w86tyrkmgjldd0w9knvran24v2hzspx"

      iex> <<0x00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262::272>>
      ...> |> BitcoinLib.Address.Bech32.from_script_hash(:testnet)
      "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7"
  """
  def from_script_hash(data, network \\ :mainnet)

  @spec from_script_hash(<<_::176>> | <<_::272>>, :mainnet | :testnet) :: binary()
  def from_script_hash(<<keyhash::bitstring-176>>, network) do
    hrp = get_hrp(network)

    SegwitAddr.encode(hrp, keyhash |> Binary.to_hex())
  end

  def from_script_hash(<<script_hash::bitstring-272>>, network) do
    hrp = get_hrp(network)

    SegwitAddr.encode(hrp, script_hash |> Binary.to_hex())
  end

  @doc """
  Applies the address's checksum to make sure it's valid

  ## Examples
      iex> "tb1qxrd42xz49clfrs5mz6thglwlu5vxmdqxsvpnks"
      ...> |> BitcoinLib.Address.Bech32.valid?()
      true
  """
  @spec valid?(binary()) :: boolean()

  def valid?("bc1" <> _ = address) do
    case SegwitAddr.decode(address) do
      {:error, "Invalid checksum"} -> false
      _ -> true
    end
  end

  def valid?("tb1" <> _ = address) do
    case SegwitAddr.decode(address) do
      {:error, "Invalid checksum"} -> false
      _ -> true
    end
  end

  def valid?(address) do
    Logger.error("#{address} is not a valid bech32 address")
  end

  def destructure(address) do
    case SegwitAddr.decode(address) do
      {:ok, {hrp, _segwit_version, encoding}} -> classify(hrp, encoding)
      {:error, message} -> {:error, "Bech32 error: #{message}"}
    end
  end

  defp classify("bc", script_hash_list) do
    script_hash =
      script_hash_list
      |> :binary.list_to_bin()

    {:ok, script_hash, :p2wpkh, :mainnet}
  end

  defp classify("tb", script_hash_list) do
    script_hash =
      script_hash_list
      |> :binary.list_to_bin()

    {:ok, script_hash, :p2wpkh, :testnet}
  end

  defp classify(prefix, _script_hash_list) do
    {:error, "#{prefix} is an unknown bech32 prefix"}
  end

  defp get_hrp(:mainnet), do: "bc"
  defp get_hrp(:testnet), do: "tb"
end
