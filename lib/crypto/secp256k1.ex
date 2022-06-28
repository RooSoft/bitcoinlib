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
