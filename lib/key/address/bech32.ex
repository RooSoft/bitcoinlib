defmodule BitcoinLib.Key.Address.Bech32 do
  @moduledoc """
  Implementation of Bech32 addresses

  BIP173: https://en.bitcoin.it/wiki/BIP_0173

  Sources:
  - https://en.bitcoin.it/wiki/Bech32
  - https://bitcointalk.org/index.php?topic=4992632.0
  """

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.PublicKey

  @doc """
  Creates a Bech32 address, which is starting by bc1, out of an Extended Public Key

  ## Examples
      iex> %BitcoinLib.Key.PublicKey{
      ...>  key: <<0x0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798::264>>,
      ...>  chain_code: 0
      ...> } |> BitcoinLib.Key.Address.Bech32.from_public_key()
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
      ...> |> BitcoinLib.Key.Address.Bech32.from_public_key_hash()
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
      ...> |> BitcoinLib.Key.Address.Bech32.from_script_hash(:testnet)
      "tb1qqrfpnq9w86tyrkmgjldd0w9knvran24v2hzspx"

      iex> <<0x00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262::272>>
      ...> |> BitcoinLib.Key.Address.Bech32.from_script_hash(:testnet)
      "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7"
  """
  def from_script_hash(data, network \\ :mainnet)

  @spec from_script_hash(<<_::176>>, :mainnet | :testnet) :: binary()
  def from_script_hash(<<keyhash::bitstring-176>>, network) do
    hrp = get_hrp(network)

    SegwitAddr.encode(hrp, keyhash |> Binary.to_hex())
  end

  @spec from_script_hash(<<_::272>>, :mainnet | :testnet) :: binary()
  def from_script_hash(<<script_hash::bitstring-272>>, network) do
    hrp = get_hrp(network)

    SegwitAddr.encode(hrp, script_hash |> Binary.to_hex())
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

  # defp interpret_decoding({:error, <<_::64, _::size(8)>>}) do
  #   {:error, "message"}
  # end

  # defp interpret_decoding({:ok, {"bc", _version, script_hash_list}}) do
  #   script_hash =
  #     script_hash_list
  #     |> :binary.list_to_bin()

  #   {:ok, script_hash, :p2wpkh, :mainnet}
  # end

  # defp interpret_decoding({:ok, {"tb", _version, script_hash_list}}) do
  #   script_hash =
  #     script_hash_list
  #     |> :binary.list_to_bin()

  #   {:ok, script_hash, :p2wpkh, :testnet}
  # end

  defp get_hrp(:mainnet), do: "bc"
  defp get_hrp(:testnet), do: "tb"
end
