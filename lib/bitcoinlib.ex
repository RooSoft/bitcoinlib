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

  def derive_public_key(private_key) do
    Public.from_private_key(private_key)
  end

  def generate_p2pkh_address(public_key) do
    public_key
    |> PublicHash.from_public_key()
    |> Address.from_public_key_hash()
  end
end
