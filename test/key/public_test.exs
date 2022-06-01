defmodule BitcoinLib.Key.PublicTest do
  use ExUnit.Case

  alias BitcoinLib.Key.Public

  test "creates a public key from a private key" do
    private_key = "0A8D286B11B98F6CB2585B627FF44D12059560ACD430DCFA1260EF2BD9569373"

    {uncompressed, compressed} =
      private_key
      |> Public.from_private_key()

    assert compressed == "020F69EF8F2FEB09B29393EEF514761F22636B90D8E4D3F2138B2373BD37523053"

    assert uncompressed ==
             "040F69EF8F2FEB09B29393EEF514761F22636B90D8E4D3F2138B2373BD37523053002119E16B613619691F760EADD486315FC9E36491C7ADB76998D1B903B3DD12"
  end
end
