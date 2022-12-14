defmodule BitcoinLib.Test.Integration.Signing.ComparisonTest do
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.PrivateKey
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Input, Output, Signer, BetterSigner}
  alias BitcoinLib.Script

  setup_all do
    private_key =
      PrivateKey.from_seed_phrase(
        "rally celery split order almost twenty ignore record legend learn chaos decade"
      )

    unsigned_transaction = %Transaction{
      version: 1,
      inputs: [
        %Input{
          txid: "e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6",
          vout: 0,
          sequence: 0xFFFFFFFF,
          script_sig:
            <<0x76A914AFC3E518577316386188AF748A816CD14CE333F288AC::200>>
            |> BitcoinLib.Script.parse!()
        }
      ],
      outputs: [
        %Output{
          script_pub_key:
            <<0x76A9283265393261373463333431393661303236653839653061643561633431386366393430613361663288AC::360>>
            |> Script.parse!(),
          value: 10_000
        }
      ],
      locktime: 0
    }

    %{
      private_key: private_key,
      unsigned_transaction: unsigned_transaction
    }
  end

  test "make sure signer and better signer results are identical", %{
    private_key: private_key,
    unsigned_transaction: unsigned_transaction
  } do
    with_signer = Signer.sign(unsigned_transaction, private_key)

    {:ok, with_better_signer} = BetterSigner.sign(unsigned_transaction, [private_key])

    assert with_signer == with_better_signer
  end
end
