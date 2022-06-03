defmodule BitcoinLib.Key.PublicTest do
  use ExUnit.Case

  doctest BitcoinLib.Key.Public

  alias BitcoinLib.Key.Public

  test "creates a public key from a private key" do
    private_key = "0a8d286b11b98f6cb2585b627ff44d12059560acd430dcfa1260ef2bd9569373"

    {uncompressed, compressed} =
      private_key
      |> Public.from_private_key()

    assert compressed == "020f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053"

    assert uncompressed ==
             "040f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053002119e16b613619691f760eadd486315fc9e36491c7adb76998d1b903b3dd12"
  end
end
