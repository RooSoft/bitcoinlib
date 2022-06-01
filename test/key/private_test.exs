defmodule BitcoinLib.Key.PrivateTest do
  use ExUnit.Case

  alias BitcoinLib.Key.Private

  test "creates a WIF from a private key" do
    private_key = 0x6C7AB2F961A1BC3F13CDC08DC41C3F439ADEBD549A8EF1C089E81A5907376107

    wif =
      private_key
      |> Private.to_wif()

    assert wif == "KzractrYn5gnDNVwBDy7sYhAkyMvX4WeYQpwyhCAUKDogJTzYsUc"
  end
end
