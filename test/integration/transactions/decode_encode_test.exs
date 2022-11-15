defmodule BitcoinLib.Test.Integration.Transactions.DecodeEncodeTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Transaction

  test "Decode and then encode a P2SH-P2WPKH transaction" do
    original_encoded =
      "01000000000101db6b1b20aa0fd7b23880be2ecbd4a98130974cf4748fb66092ac4d3ceb1a5477010000001716001479091972186c449eb1ded22b78e40d009bdf0089feffffff02b8b4eb0b000000001976a914a457b684d7f0d539a46a45bbc043f35b59d0d96388ac0008af2f000000001976a914fd270b1ee6abcaea97fea7ad0402e8bd8ad6d77c88ac02473044022047ac8e878352d3ebbde1c94ce3a10d057c24175747116f8288e5d794d12d482f0220217f36a485cae903c713331d877c1f64677e3622ad4010726870540656fe9dcb012103ad1d8e89212f0b92c74d23bb710c00662ad1470198ac48c43f7d6f93a2a2687392040000"

    {:ok, transaction, <<>>} = Transaction.parse(original_encoded)
    new_encoded = Transaction.encode(transaction) |> Binary.to_hex()

    assert transaction.locktime == 0x492
    assert Enum.count(transaction.witness) > 0
    assert new_encoded == original_encoded
  end
end
