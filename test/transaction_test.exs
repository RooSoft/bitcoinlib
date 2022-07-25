defmodule BitcoinLib.TransactionTest do
  use ExUnit.Case, async: true

  doctest BitcoinLib.Transaction

  alias BitcoinLib.Transaction

  test "decode a transaction" do
    # should be
    #{
    #     "addresses": [
    #       "1KaNd8ybzTDYKpyMB9X2dstvMwo5ogo5bT"
    #   ],
    #   "block_height": -1,
    #   "block_index": -1,
    #   "confirmations": 0,
    #   "double_spend": false,
    #   "fees": 0,
    #   "hash": "c80b343d2ce2b5d829c2de9854c7c8d423c0e33bda264c40138d834aab4c0638",
    #   "inputs": [
    #       {
    #           "age": 0,
    #           "output_index": 0,
    #           "prev_hash": "3f4fa19803dec4d6a84fae3821da7ac7577080ef75451294e71f9b20e0ab1e7b",
    #           "script_type": "empty",
    #           "sequence": 4294967295
    #       }
    #   ],
    #   "outputs": [
    #       {
    #           "addresses": [
    #               "1KaNd8ybzTDYKpyMB9X2dstvMwo5ogo5bT"
    #           ],
    #           "script": "76a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac",
    #           "script_type": "pay-to-pubkey-hash",
    #           "value": 4999990000
    #       }
    #   ],
    #   "preference": "low",
    #   "received": "2022-07-21T19:01:04.711615752Z",
    #   "relayed_by": "34.233.71.74",
    #   "size": 85,
    #   "total": 4999990000,
    #   "ver": 1,
    #   "vin_sz": 1,
    #   "vout_sz": 1,
    #   "vsize": 85
    # }

    raw =
      "01000000017b1eabe0209b1fe794124575ef807057c77ada2138ae4fa8d6c4de0398a14f3f0000000000ffffffff01f0ca052a010000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac00000000"
      |> Binary.from_hex

    transaction = Transaction.decode(raw)

    assert 1 == transaction.input_count
  end
end
