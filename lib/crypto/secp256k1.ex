defmodule BitcoinLib.Crypto.Secp256k1 do
  @moduledoc """
  Elliptic curve cryptography

  Based on https://hexdocs.pm/curvy/Curvy.html
  """

  alias Curvy.{Point, Key}
  alias BitcoinLib.Key.{PrivateKey, PublicKey}

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
      ...> private_key = %BitcoinLib.Key.PrivateKey{key: <<0xd6ead233e06c068585976b5c8373861d77e7f030ec452e65ee81c85fa6906970::256>>}
      ...> BitcoinLib.Crypto.Secp256k1.sign(message, private_key)
  """
  @spec sign(binary(), %PrivateKey{}) :: bitstring()
  def sign(message, %PrivateKey{key: key}) do
    key = Key.from_privkey(key)

    Curvy.sign(message, key, hash: :secp256k1)
  end

  @doc """
  Validates a signature

  ## Examples
      iex> signature = <<0x3044022048b3b0eb98ae5f2c997e41a2630a5e3512f24a1f5b6165e2867847a11b2b22350220032211844eec911dab6d91836a45c37ca1d498433d87b6b09e2f401025131a05::560>>
      ...> message = "76a914c825a1ecf2a6830c4401620c3a16f1995057c2ab88ac"
      ...> public_key = <<0x02702ded1cca9816fa1a94787ffc6f3ace62cd3b63164f76d227d0935a33ee48c3::264>>
      ...> BitcoinLib.Crypto.Secp256k1.validate(signature, message, public_key)
      true
  """
  @spec validate(bitstring(), bitstring(), %PublicKey{} | bitstring()) :: boolean()
  def validate(signature, message, %PublicKey{key: key}) do
    validate(signature, message, key)
  end

  def validate(signature, message, public_key)
      when is_binary(public_key) and (byte_size(public_key) == 33 or byte_size(public_key) == 65) do
    key = Key.from_pubkey(public_key)

    Curvy.verify(signature, message, key, hash: :secp256k1)
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
