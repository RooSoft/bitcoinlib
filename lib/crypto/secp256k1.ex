defmodule BitcoinLib.Crypto.Secp256k1 do
  @moduledoc """
  Elliptic curve cryptography

  Based on https://hexdocs.pm/curvy/Curvy.html
  """

  alias Curvy.{Point, Key}

  @doc """
  Add two keys on the elliptic curve using Jacobian Point mathematics

  ## Examples
    iex> key1 = 0x2E65A9C40338B8D07D72CD82BF3C9DDD0375F362863BC0808E6AD194F19F5EBA0
    ...> key2 = 0x2702DED1CCA9816FA1A94787FFC6F3ACE62CD3B63164F76D227D0935A33EE48C3
    ...> BitcoinLib.Crypto.Secp256k1.add_keys(key1, key2)
    0x2FC5BA55A539899D67EE66E99EE50AB59DCCBB122025D18C5EB9446D380A9EC0A
  """
  def add_keys(key1, key2) do
    point1 = get_point(key1)
    point2 = get_point(key2)

    add_points(point1, point2)
    |> to_integer()
  end

  @doc """
  Signs a message using a private key

  ## Examples
    iex> message = "76a914c825a1ecf2a6830c4401620c3a16f1995057c2ab88ac"
    ...> private_key = "5d56c06f7aff6e62d909e786f4e869b8fb6c031b877e494149ca126bd550fc30"
    ...> BitcoinLib.Crypto.Secp256k1.sign(message, private_key)
    "304402207c2650166f802c3d4bdc6b636bf0678dce4ffb72008e292ac7e628f7a066f321022038876bf9cd69cb1e676429d0fdac17dffa0e10c265b8d9f508c42bff53fe23d6"
  """
  def sign(message, private_key) do
    key =
      private_key
      |> Binary.from_hex()
      |> Key.from_privkey()

    Curvy.sign(message, key)
    |> Binary.to_hex()
  end

  defp get_point(key) do
    key
    |> Binary.from_integer()
    |> Key.from_pubkey()
    |> Map.get(:point)
  end

  defp add_points(point1, point2) do
    Point.add(point1, point2)
  end

  defp to_integer(point) do
    point
    |> Key.from_point()
    |> Key.to_pubkey()
    |> Binary.to_integer()
  end
end
