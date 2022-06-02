defmodule BitcoinLib do
  alias BitcoinLib.Key.{Private, Public, PublicHash, Address}

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
