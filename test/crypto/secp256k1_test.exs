defmodule BitcoinLib.Crypto.Secp256k1Test do
  use ExUnit.Case

  doctest BitcoinLib.Crypto.Secp256k1

  alias BitcoinLib.Crypto.Secp256k1
  alias BitcoinLib.Key.{PrivateKey, PublicKey}

  test "add two keys" do
    key1 = <<0x2E65A9C40338B8D07D72CD82BF3C9DDD0375F362863BC0808E6AD194F19F5EBA0::264>>
    key2 = <<0x2702DED1CCA9816FA1A94787FFC6F3ACE62CD3B63164F76D227D0935A33EE48C3::264>>

    sum = Secp256k1.add_keys(key1, key2)

    assert sum == <<0x2FC5BA55A539899D67EE66E99EE50AB59DCCBB122025D18C5EB9446D380A9EC0A::264>>
  end

  test "sign and verify a message" do
    message = "76a914c825a1ecf2a6830c4401620c3a16f1995057c2ab88ac"

    private_key = %PrivateKey{
      key: <<0xD6EAD233E06C068585976B5C8373861D77E7F030EC452E65EE81C85FA6906970::256>>
    }

    public_key = PublicKey.from_private_key(private_key)

    signature = Secp256k1.sign(message, private_key)

    is_valid = Secp256k1.validate(signature, message, public_key)

    assert is_valid
  end
end
