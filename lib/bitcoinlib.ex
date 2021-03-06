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
  @spec generate_private_key() :: %{raw: integer(), wif: binary()}
  def generate_private_key do
    Private.generate()
  end

  @doc """
  Derives a public key from a raw private key

  ## Examples

    iex> 0x0a8d286b11b98f6cb2585b627ff44d12059560acd430dcfa1260ef2bd9569373
    ...> |> BitcoinLib.derive_public_key()
    {
      0x040f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053002119e16b613619691f760eadd486315fc9e36491c7adb76998d1b903b3dd12,
      0x020f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053
    }
  """
  @spec derive_public_key(integer()) :: {integer(), integer()}
  def derive_public_key(private_key) do
    Public.from_private_key(private_key)
  end

  @doc """
  Creates a P2PKH address from a public key

  ## Examples

    iex> 0x020f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053
    ...> |> BitcoinLib.generate_p2pkh_address()
    "1Ak9NVPmwCHEpsSWvM6cNRC7dsYniRmwMG"
  """
  @spec generate_p2pkh_address(integer()) :: binary()
  def generate_p2pkh_address(public_key) do
    public_key
    |> PublicHash.from_public_key()
    |> Address.from_public_key_hash(:p2pkh)
  end
end
