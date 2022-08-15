defmodule BitcoinLib.Key.HD.Hmac do
  @moduledoc """
  Computes HMAC on either a public or a private key in the aim of computing
  a child key
  """

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.HD.{ExtendedPublic, ExtendedPrivate}

  @doc """
  Computes HMAC on either a public or a private key in the aim of computing
  a child key

  ## Examples
    iex> %BitcoinLib.Key.HD.ExtendedPrivate {
    ...>   key: <<0xE8F32E723DECF4051AEFAC8E2C93C9C5B214313817CDB01A1494B917C8436B35::256>>,
    ...>   chain_code: <<0x873DFF81C02F525623FD1FE5167EAC3A55A049DE3D314BB42EE227FFED37D508::256>>
    ...> }
    ...> |> BitcoinLib.Key.HD.Hmac.compute(0)
    {
      <<0x6539AE80B3618C22F5F8CC4171D04835570BDA8DB11B5BF1779AFAE7EC7C79C3::256>>,
      <<0xD323F1BE5AF39A2D2F08F5E8F664633849653DBE329802E9847CFC85F8D7B52A::256>>
    }
  """
  def compute(private_key, index, hardened? \\ false)

  def compute(%ExtendedPrivate{} = private_key, index, hardened? = false) do
    private_key
    |> ExtendedPublic.from_private_key()
    |> compute(index, hardened?)
  end

  def compute(%ExtendedPrivate{} = private_key, index, hardened? = true) do
    get_input(private_key, index, hardened?)
    |> execute(private_key.chain_code)
  end

  def compute(%ExtendedPublic{} = public_key, index, hardened?) do
    get_input(public_key, index, hardened?)
    |> execute(public_key.chain_code)
  end

  defp get_input(%ExtendedPrivate{} = private_key, index, _hardened? = true)
       when is_integer(index) do
    <<(<<0>>), private_key.key::bitstring, index::size(32)>>
  end

  defp get_input(%ExtendedPublic{} = public_key, index, _hardened? = false)
       when is_integer(index) do
    key = public_key.key

    <<key::bitstring, index::size(32)>>
  end

  defp execute(hmac_input, chain_code) do
    <<derived_key::bitstring-256, child_chain::bitstring-256>> =
      hmac_input
      |> Crypto.hmac_bitstring(chain_code)

    {derived_key, child_chain}
  end
end
