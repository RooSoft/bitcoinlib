defmodule BitcoinLib.Key.PublicKey.ChildFromIndexTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.PublicKey.ChildFromIndex

  alias BitcoinLib.Key.PublicKey
  alias BitcoinLib.Key.PublicKey.ChildFromIndex

  test "Get a private key child from a derivation path" do
    public_key =
      "xpub661MyMwAqRbcG9f9XvWiQv4QoTjumJK1MYjvzg9ryCfaGkPymrT9cmxeD6cJeR1rMVbDNopS6MfmawkHGVojnQa3zuRT2uwGJLT1STLLUXs"
      |> PublicKey.deserialize!()

    index = 0

    {:ok, child_pub_key} = ChildFromIndex.get(public_key, index)

    assert child_pub_key |> PublicKey.serialize!() ==
             "xpub68EMPgybEdJKPbMeHddaRysY164ydrajq2u2BxkrdQxtkufYN3vjT7JcEtLmstG8tviUfqGNCh9G7K2Q9CTJZZR8F4YMrWff5zjHqZXH5JL"
  end
end
