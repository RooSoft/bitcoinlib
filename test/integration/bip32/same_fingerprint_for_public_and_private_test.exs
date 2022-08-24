defmodule BitcoinLib.Test.Integration.Bip32.SameFingerprintForPublicAndPrivateTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Key.HD.{Fingerprint}

  test "make sure the fingerprint is the same for a private key and it's public key" do
    private_key = %PrivateKey{
      key: <<0x30A6B59CCCC924FC9FFD4AB08C5C01F0D6A4046797BB255D8919EB3E95C08871::256>>,
      chain_code: <<0xE08FCC54429E47AC55FEBD4DC9EDCCC88D292EB40AA3765AF3DA7178A14AA114::256>>
    }

    public_key = private_key |> PublicKey.from_private_key()

    private_fingerprint = Fingerprint.compute(private_key)
    public_fingerprint = Fingerprint.compute(public_key)

    assert private_fingerprint == public_fingerprint
  end
end
