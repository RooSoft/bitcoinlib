defmodule BitcoinLib.Signing.Psbt.Keypair do
  @moduledoc """
  Extracts a keypair from a binary according to the
  [specification](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki#specification)

  <keypair> := <key> <value>
  <key> := <keylen> <keytype> <keydata>
  <value> := <valuelen> <valuedata>
  """
  defstruct [:key, :value]

  alias BitcoinLib.Signing.Psbt.Keypair
  alias BitcoinLib.Signing.Psbt.Keypair.{Key, Value}

  def extract_from(data) do
    {key, data} = extract_key(data)
    {value, data} = extract_value(data)

    {%Keypair{key: key, value: value}, data}
  end

  defp extract_key(data), do: Key.extract_from(data)
  defp extract_value(data), do: Value.extract_from(data)
end
