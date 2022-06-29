defmodule BitcoinLib.Key.HD.Fingerprint do
  @moduledoc """
  A fingerprint is a small hash of a public key
  """
  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.{ExtendedPublic, ExtendedPrivate}

  @doc """
  Compute a private key's fingerprint

  ## Examples
    iex> %BitcoinLib.Key.HD.ExtendedPrivate {
    ...>   key: 0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35,
    ...>   chain_code: 0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508
    ...> }
    ...> |> BitcoinLib.Key.HD.Fingerprint.compute()
    0x3442193E
  """
  def compute(%ExtendedPrivate{} = private_key) do
    private_key
    |> to_public_key
    |> compute
  end

  def compute(%ExtendedPublic{} = public_key) do
    <<raw_fingerprint::binary-4, _rest::binary>> =
      public_key.key
      |> Binary.from_integer()
      |> Crypto.hash160_bitstring()

    raw_fingerprint
    |> Binary.to_integer()
  end

  defp to_public_key(%ExtendedPrivate{} = private_key) do
    private_key
    |> ExtendedPublic.from_private_key()
  end
end
