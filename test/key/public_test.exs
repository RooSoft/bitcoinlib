defmodule BitcoinLib.Key.PublicTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.Public

  alias BitcoinLib.Key.Public

  test "creates a public key from a private key" do
    private_key = <<0x0A8D286B11B98F6CB2585B627FF44D12059560ACD430DCFA1260EF2BD9569373::256>>

    {uncompressed, compressed} =
      private_key
      |> Public.from_private_key()

    assert <<0x020F69EF8F2FEB09B29393EEF514761F22636B90D8E4D3F2138B2373BD37523053::264>> ==
             compressed

    assert <<0x040F69EF8F2FEB09B29393EEF514761F22636B90D8E4D3F2138B2373BD37523053002119E16B613619691F760EADD486315FC9E36491C7ADB76998D1B903B3DD12::520>> ==
             uncompressed
  end
end
