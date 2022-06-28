defmodule BitcoinLib.Key.HD.ExtendedPublic.ChildFromIndexTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Key.HD.ExtendedPublic.ChildFromIndex

  alias BitcoinLib.Key.HD.{ExtendedPublic}
  alias BitcoinLib.Key.HD.ExtendedPublic.ChildFromIndex

  test "Get a private key child from a derivation path" do
    public_key =
      "xpub661MyMwAqRbcG9f9XvWiQv4QoTjumJK1MYjvzg9ryCfaGkPymrT9cmxeD6cJeR1rMVbDNopS6MfmawkHGVojnQa3zuRT2uwGJLT1STLLUXs"
      |> ExtendedPublic.deserialize()

    index = 0

    child_pub_key = ChildFromIndex.get(public_key, index)

    assert child_pub_key |> to_xpub ==
             "xpub68EMPgybEdJKPbMeHddaRysY164ydrajq2u2BxkrdQxtkufYN3vjT7JcEtLmstG8tviUfqGNCh9G7K2Q9CTJZZR8F4YMrWff5zjHqZXH5JL"
  end

  defp to_xpub(public_key) do
    public_key
    |> elem(1)
    |> ExtendedPublic.serialize()
  end
end
