defmodule BitcoinLib.Key.Encoding do
  @moduledoc """
  Encodes public or private keys
  """

  @version %{
    mainnet_private: <<4, 136, 173, 228>>,
    mainnet_public: <<4, 136, 178, 30>>,
    testnet_private: <<4, 53, 131, 148>>,
    testnet_public: <<4, 53, 135, 207>>
  }

  alias BitcoinLib.Crypto

  def encode_master(key, chain_code) do
    version_number = <<4, 136, 173, 228>>
    depth = <<0>>
    fingerprint = <<0::32>>
    index = <<0::32>>

    prefixed_key = prefix_private_key(key, version_number)

    encode_extended_key(version_number, depth, fingerprint, index, chain_code, prefixed_key)
  end

  def encode_extended_key(version_number, depth, fingerprint, index, chain_code, key) do
    <<version_number::bitstring, depth::bitstring, fingerprint::bitstring, index::bitstring,
      chain_code::bitstring, key::bitstring>>
    |> append_checksum
    |> Base58.encode()
  end

  defp private_version_number(:mainnet), do: @version.mainnet_private
  defp private_version_number(:testnet), do: @version.testnet_private

  defp prefix_private_key(key, version) do
    if version == private_version_number(:mainnet) or version == private_version_number(:testnet) do
      <<0::size(8), key::bitstring>>
    else
      key
    end
  end

  defp append_checksum(data) do
    checksum = Crypto.checksum_bitstring(data)

    <<data::binary, checksum::binary>>
  end
end
