defmodule BitcoinLib do
  alias BitcoinLib.Key.{Private, Public}

  def generate_private_key do
    Private.generate()
  end

  def derive_public_key(private_key) do
    Public.from_private_key(private_key)
  end

  def generate_p2pkh_address(public_key) do
    Public.to_address(public_key)
  end
end
