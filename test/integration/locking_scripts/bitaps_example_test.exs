defmodule BitcoinLib.Test.Integration.LockingScripts.BitapsExampleTest do
  @moduledoc """
  bitaps example from medium.com
  https://medium.com/@bitaps.com/exploring-bitcoin-signing-the-p2pkh-input-b8b4d5c4809c#50a6
  """
  use ExUnit.Case, async: true

  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Input, Output}
  alias BitcoinLib.Script
  alias BitcoinLib.Crypto

  @doc """
  We have 1.3 tBTC on mvJe9AfPLrxpfHwjLNjDAiVsFSzwBGaMSP and want transfer it to n4AYuETorj4gYKendz2ndm9QhjUuruZnfk

  Private Key: cThjSL4HkRECuDxUTnfAmkXFBEg78cufVBy3ZfEhKoxZo6Q38R5L
  Address: mvJe9AfPLrxpfHwjLNjDAiVsFSzwBGaMSP
  Input transaction: 5e2383defe7efcbdc9fdd6dba55da148b206617bbb49e6bb93fce7bfbb459d44
  Input transaction output: 1
  Input amount:  1.3000000
  """
  test "bitcoin testnet signing P2PKH" do
    private_key =
      "cThjSL4HkRECuDxUTnfAmkXFBEg78cufVBy3ZfEhKoxZo6Q38R5L"
      |> PrivateKey.from_wif()

    public_key =
      private_key
      |> PublicKey.from_private_key()

    # the transaction can be found in a block explorer such as here:
    # https://mempool.space/testnet/tx/5e2383defe7efcbdc9fdd6dba55da148b206617bbb49e6bb93fce7bfbb459d44

    # we use the second UTXO's script pub key from the output in the above transaction:
    redeem_script =
      <<0x76A914A235BDDE3BB2C326F291D9C281FDC3FE1E956FE088AC::200>>
      |> Script.parse()

    # found straight in the output of step1 in here:
    # https://medium.com/@bitaps.com/exploring-bitcoin-signing-the-p2pkh-input-b8b4d5c4809c#50a6
    locking_script =
      <<0x76A914F86F0BC0A2232970CCDF4569815DB500F126836188AC::200>>
      |> Script.parse()

    transaction_hex =
      %Transaction{
        version: 1,
        inputs: [
          %Input{
            txid: "5e2383defe7efcbdc9fdd6dba55da148b206617bbb49e6bb93fce7bfbb459d44",
            vout: 1,
            sequence: 0xFFFFFFFF,
            script_sig: redeem_script
          }
        ],
        outputs: [%Output{script_pub_key: locking_script, value: 129_000_000}],
        locktime: 0
      }
      |> Transaction.encode()

    # sign this transaction
    preimage =
      transaction_hex
      |> append_sighash(1)

    hashed_preimage =
      preimage
      |> Crypto.double_sha256()

    # DER Encoding reference https://github.com/bitcoin/bips/blob/master/bip-0066.mediawiki#der-encoding-reference
    # must implement DER verification in PrivateKey.sign_message/2 to make sure signatures are valid
    # might also be useful https://github.com/bitcoin/bips/blob/master/bip-0137.mediawiki
    # etotheipi's diagram: https://en.bitcoin.it/wiki/File:Bitcoin_OpCheckSig_InDetail.png
    # OP_CHECKSIG: https://en.bitcoin.it/wiki/OP_CHECKSIG
    # >>>>>>> check this out https://bitcoin.stackexchange.com/questions/3374/how-to-redeem-a-basic-tx <<<<<<<<<<<<
    signature =
      hashed_preimage
      |> PrivateKey.sign_message(private_key)

    is_valid =
      signature
      |> PublicKey.validate_signature(hashed_preimage, public_key)

    assert true == is_valid
  end

  defp append_sighash(transaction, sighash) do
    <<transaction::bitstring, sighash::little-32>>
  end
end
