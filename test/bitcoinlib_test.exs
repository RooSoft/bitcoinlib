defmodule BitcoinLib.Test do
  use ExUnit.Case, async: true

  doctest BitcoinLib

  alias BitcoinLib.Key.{PrivateKey, PublicKey}

  test "generate a private key: raw version" do
    %{raw: private_key} = BitcoinLib.generate_private_key()

    assert is_bitstring(private_key)
  end

  test "generate a private key: wif version" do
    %{wif: private_key} = BitcoinLib.generate_private_key()

    assert is_binary(private_key)
    assert byte_size(private_key) == 52
  end

  test "public key derivation from a private key" do
    private_key = %PrivateKey{
      key: <<0x0A8D286B11B98F6CB2585B627FF44D12059560ACD430DCFA1260EF2BD9569373::256>>
    }

    public_key =
      private_key
      |> BitcoinLib.derive_public_key()

    assert %BitcoinLib.Key.PublicKey{
             key: <<0x020F69EF8F2FEB09B29393EEF514761F22636B90D8E4D3F2138B2373BD37523053::264>>,
             fingerprint: <<0x6AE20179::32>>,
           } = public_key
  end

  test "generate a P2PKH address from a public key" do
    public_key = %PublicKey{
      key: <<0x020F69EF8F2FEB09B29393EEF514761F22636B90D8E4D3F2138B2373BD37523053::264>>
    }

    address =
      public_key
      |> BitcoinLib.generate_p2pkh_address()

    assert address == "1Ak9NVPmwCHEpsSWvM6cNRC7dsYniRmwMG"
  end
end
