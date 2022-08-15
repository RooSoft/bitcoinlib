defmodule BitcoinLib.Crypto.Secp256k1Test do
  use ExUnit.Case

  doctest BitcoinLib.Crypto.Secp256k1

  alias BitcoinLib.Crypto.Secp256k1

  test "add two keys" do
    key1 = <<0x2E65A9C40338B8D07D72CD82BF3C9DDD0375F362863BC0808E6AD194F19F5EBA0::264>>
    key2 = <<0x2702DED1CCA9816FA1A94787FFC6F3ACE62CD3B63164F76D227D0935A33EE48C3::264>>

    sum = Secp256k1.add_keys(key1, key2)

    assert sum == <<0x2FC5BA55A539899D67EE66E99EE50AB59DCCBB122025D18C5EB9446D380A9EC0A::264>>
  end
end
