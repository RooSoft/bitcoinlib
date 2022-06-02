defmodule BitcoinLib do
  @moduledoc """
  High level bitcoin operations
  """

  alias BitcoinLib.Key.{Private, Public, PublicHash, Address}

  @doc """
  Creates a bitcoin private key both in raw and WIF format

  ## Examples

    iex> %{raw: _, wif: _} = BitcoinLib.generate_private_key()
  """
  def generate_private_key do
    Private.generate()
  end

  @doc """
  Derives a public key from a raw private key

  ## Examples

    iex> "0a8d286b11b98f6cb2585b627ff44d12059560acd430dcfa1260ef2bd9569373" |> BitcoinLib.derive_public_key()
    {
      "040f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053002119e16b613619691f760eadd486315fc9e36491c7adb76998d1b903b3dd12",
      "020f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053"
    }
  """
  def derive_public_key(private_key) do
    Public.from_private_key(private_key)
  end

  def generate_p2pkh_address(public_key) do
    public_key
    |> PublicHash.from_public_key()
    |> Address.from_public_key_hash()
  end
end
