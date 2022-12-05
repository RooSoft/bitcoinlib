defmodule BitcoinLib.Signing.Psbt.Keypair.Key do
  @moduledoc """
  Extracts a keypair's key from a binary according to the
  [specification](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki#specification)

  <key> := <keylen> <keytype> <keydata>
  """
  defstruct [:length, :type, :data]

  @byte 8

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Signing.Psbt.Keypair.Key

  @type t :: Key

  # TODO: doctests
  @doc """
  Extracts a key from some arbitrary data, returning a tuple containing the key and the remaining data
  """
  @spec extract_from(binary()) :: {Key.t(), binary}
  def extract_from(data) do
    extracted =
      %{key: %Key{}, data: data}
      |> extract_keylen()
      |> extract_keytype()
      |> extract_keydata()

    {extracted.key, extracted.data}
  end

  defp extract_keylen(%{data: data} = map) do
    %{value: keylen, remaining: data} = CompactInteger.extract_from(data)

    key = %Key{length: keylen}

    %{map | key: key, data: data}
  end

  defp extract_keytype(%{key: key, data: data} = map) do
    %{value: key_type, size: key_type_length, remaining: data} = CompactInteger.extract_from(data)

    key = %Key{key | type: key_type}

    %{map | key: key, data: data}
    |> Map.put(:key_type_length, key_type_length)
  end

  defp extract_keydata(%{key: key, key_type_length: key_type_length, data: data} = map) do
    key_data_length = key.length * @byte - key_type_length

    <<key_data::bitstring-size(key_data_length), data::bitstring>> = data

    key =
      key
      |> Map.put(:data, key_data)

    %{map | key: key, data: data}
  end
end
