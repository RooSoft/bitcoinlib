defmodule BitcoinLib.Test do
  use ExUnit.Case

  doctest BitcoinLib

  test "generate a private key: raw version" do
    %{raw: private_key} = BitcoinLib.generate_private_key()

    assert is_integer(private_key)
  end

  test "generate a private key: wif version" do
    %{wif: private_key} = BitcoinLib.generate_private_key()

    assert is_binary(private_key)
    assert byte_size(private_key) == 52
  end

  test "public key derivation from a private key" do
    private_key = "0a8d286b11b98f6cb2585b627ff44d12059560acd430dcfa1260ef2bd9569373"

    {uncompressed, compressed} =
      private_key
      |> BitcoinLib.derive_public_key()

    assert uncompressed ==
             "04" <>
               "0f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053" <>
               "002119e16b613619691f760eadd486315fc9e36491c7adb76998d1b903b3dd12"

    assert compressed ==
             "02" <>
               "0f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053"
  end

  test "generate a P2PKH address from a public key" do
    public_key = "020f69ef8f2feb09b29393eef514761f22636b90d8e4d3f2138b2373bd37523053"

    address =
      public_key
      |> BitcoinLib.generate_p2pkh_address()

    assert address == "1Ak9NVPmwCHEpsSWvM6cNRC7dsYniRmwMG"
  end
end
