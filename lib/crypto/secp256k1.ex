defmodule BitcoinLib.Crypto.Secp256k1 do
  @moduledoc """
  Elliptic curve cryptography

  Based on https://hexdocs.pm/curvy/Curvy.html
  """

  # , Signature}
  alias Curvy.{Point, Key}

  @doc """
  Add two keys on the elliptic curve using Jacobian Point mathematics

  ## Examples
    iex> key1 = <<0x2E65A9C40338B8D07D72CD82BF3C9DDD0375F362863BC0808E6AD194F19F5EBA0::264>>
    ...> key2 = <<0x2702DED1CCA9816FA1A94787FFC6F3ACE62CD3B63164F76D227D0935A33EE48C3::264>>
    ...> BitcoinLib.Crypto.Secp256k1.add_keys(key1, key2)
    <<0x2FC5BA55A539899D67EE66E99EE50AB59DCCBB122025D18C5EB9446D380A9EC0A::264>>
  """
  def add_keys(key1, key2) do
    point1 = get_point(key1)
    point2 = get_point(key2)

    add_points(point1, point2)
    |> to_pubkey
  end

  @doc """
  Signs a message using a private key

  Below is an example of a signature... this doctest doesn't end with a value, because the signature
  is different on every call, and even can have different lengths.

  ## Examples
    iex> message = "76a914c825a1ecf2a6830c4401620c3a16f1995057c2ab88ac"
    ...> private_key = <<0xd6ead233e06c068585976b5c8373861d77e7f030ec452e65ee81c85fa6906970::256>>
    ...> BitcoinLib.Crypto.Secp256k1.sign(message, private_key)
  """
  def sign(message, private_key) do
    :crypto.sign(:ecdsa, :sha256, message, [private_key, :secp256k1])
  end

  @doc """
  Validates a signature

  ## Examples
    iex> signature = <<0x304402202a849a7fc3ba88a8c8958ae525b2fcd4f24dc58f22bbc5c461c24c1c54b985c60220711e2bb8a18eefd5c58e9191fb66b42846a1b8233846a41908059be65ffa1dcc::560>>
    ...> message = "76a914725ebac06343111227573d0b5287954ef9b88aae88ac"
    ...> public_key = <<0x02702ded1cca9816fa1a94787ffc6f3ace62cd3b63164f76d227d0935a33ee48c3::264>>
    ...> BitcoinLib.Crypto.Secp256k1.validate(signature, message, public_key)
    true
  """
  def validate(signature, message, public_key) do
    :crypto.verify(:ecdsa, :sha256, message, signature, [public_key, :secp256k1])
  end

  defp get_point(key) do
    key
    |> Key.from_pubkey()
    |> Map.get(:point)
  end

  defp add_points(point1, point2) do
    Point.add(point1, point2)
  end

  defp to_pubkey(point) do
    point
    |> Key.from_point()
    |> Key.to_pubkey()
  end
end
