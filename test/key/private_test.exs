defmodule BitcoinLib.Key.PrivateTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.Private

  alias BitcoinLib.Key.Private

  test "creates a WIF from a private key" do
    private_key =
      <<108, 122, 178, 249, 97, 161, 188, 63, 19, 205, 192, 141, 196, 28, 63, 67, 154, 222, 189,
        84, 154, 142, 241, 192, 137, 232, 26, 89, 7, 55, 97, 7>>

    wif =
      private_key
      |> Private.to_wif()

    assert wif == "KzractrYn5gnDNVwBDy7sYhAkyMvX4WeYQpwyhCAUKDogJTzYsUc"
  end
end
