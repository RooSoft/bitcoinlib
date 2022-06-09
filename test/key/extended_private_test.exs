defmodule BitcoinLib.Key.ExtendedPrivateTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.ExtendedPrivate

  alias BitcoinLib.Key.ExtendedPrivate

  test "creates a WIF from a private key" do
    seed =
      "67f93560761e20617de26e0cb84f7234aaf373ed2e66295c3d7397e6d7ebe882ea396d5d293808b0defd7edd2babd4c091ad942e6a9351e6d075a29d4df872af"

    extended_private_key =
      seed
      |> ExtendedPrivate.from_seed()

    assert %{
             chain_code: _,
             private_key: _
           } = extended_private_key
  end
end
