defmodule BitcoinLib.Signing.Psbt.Keypair.Key do
  @moduledoc """
  Extracts a keypair's key from a binary according to the
  [specification](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki#specification)

  <key> := <keylen> <keytype> <keydata>
  <value> := <valuelen> <valuedata>
  """
  defstruct [:keylen, :keytype, :keydata]

  @byte 8

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Signing.Psbt.Keypair.Key

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

    key = %Key{keylen: keylen}

    %{map | key: key, data: data}
  end

  defp extract_keytype(%{key: key, data: data} = map) do
    %{value: keytype, size: keytype_length, remaining: data} = CompactInteger.extract_from(data)

    key = %Key{key | keytype: keytype}

    %{map | key: key, data: data}
    |> Map.put(:keytype_length, keytype_length)
  end

  defp extract_keydata(%{key: key, keytype_length: keytype_length, data: data} = map) do
    keydata_length = key.keylen * @byte - keytype_length

    <<keydata::size(keydata_length), data::bitstring>> = data

    key =
      key
      |> Map.put(:keydata, keydata)

    %{map | key: key, data: data}
  end
end
