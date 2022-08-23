defmodule BitcoinLib.Key.HD.Fingerprint do
  @moduledoc """
  A fingerprint is a small hash of a public key
  """
  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.{PrivateKey}
  alias BitcoinLib.Key.HD.{ExtendedPublic}

  @doc """
  Compute a private key's fingerprint

  ## Examples
    iex> %BitcoinLib.Key.PrivateKey {
    ...>   key: <<0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35::256>>,
    ...>   chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>
    ...> }
    ...> |> BitcoinLib.Key.HD.Fingerprint.compute()
    <<0x3442193E::32>>

    iex> %BitcoinLib.Key.HD.ExtendedPublic{
    ...>   key: <<0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9::264>>,
    ...>   chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    ...> }
    ...> |> BitcoinLib.Key.HD.Fingerprint.compute()
    <<0x18C1259::32>>
  """
  @spec compute(%PrivateKey{}) :: binary()
  def compute(%PrivateKey{} = private_key) do
    private_key
    |> to_public_key
    |> compute
  end

  @spec compute(%ExtendedPublic{}) :: binary()
  def compute(%ExtendedPublic{} = public_key) do
    <<raw_fingerprint::binary-4, _rest::binary>> =
      public_key.key
      |> Crypto.hash160_bitstring()

    raw_fingerprint
  end

  @doc """
  Adds a fingerprint to a public key

  ## Examples
    iex> %BitcoinLib.Key.PrivateKey {
    ...>   key: <<0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35::256>>,
    ...>   chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>
    ...> }
    ...> |> BitcoinLib.Key.HD.Fingerprint.append()
    %BitcoinLib.Key.PrivateKey {
      fingerprint: <<0x3442193E::32>>,
      key: <<0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35::256>>,
      chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>
    }

    iex> %BitcoinLib.Key.HD.ExtendedPublic{
    ...>   key: <<0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9::264>>,
    ...>   chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    ...> }
    ...> |> BitcoinLib.Key.HD.Fingerprint.append()
    %BitcoinLib.Key.HD.ExtendedPublic{
      fingerprint: <<0x18C1259::32>>,
      key: <<0x252C616D91A2488C1FD1F0F172E98F7D1F6E51F8F389B2F8D632A8B490D5F6DA9::264>>,
      chain_code: <<0x463223AAC10FB13F291A1BC76BC26003D98DA661CB76DF61E750C139826DEA8B::256>>
    }
  """
  @spec append(%PrivateKey{}) :: %PrivateKey{}
  def append(%PrivateKey{} = private_key) do
    fingerprint =
      private_key
      |> compute()

    private_key
    |> Map.put(:fingerprint, fingerprint)
  end

  @spec append(%ExtendedPublic{}) :: %ExtendedPublic{}
  def append(%ExtendedPublic{} = public_key) do
    fingerprint =
      public_key
      |> compute()

    public_key
    |> Map.put(:fingerprint, fingerprint)
  end

  defp to_public_key(%PrivateKey{} = private_key) do
    private_key
    |> ExtendedPublic.from_private_key()
  end
end
