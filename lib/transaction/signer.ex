defmodule BitcoinLib.Transaction.Signer do
  @moduledoc """
  Signs transactions
  """

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Transaction
  alias BitcoinLib.Script
  alias BitcoinLib.Script.Opcodes

  @doc """
  Takes a transaction and signs it with the private key that's in the second parameter

  ## Examples
      iex>  private_key = BitcoinLib.Key.PrivateKey.from_seed_phrase(
      ...>    "rally celery split order almost twenty ignore record legend learn chaos decade"
      ...>  )
      ...>  %BitcoinLib.Transaction{
      ...>    version: 1,
      ...>    inputs: [
      ...>      %BitcoinLib.Transaction.Input{
      ...>        txid: "e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6",
      ...>        vout: 0,
      ...>        sequence: 0xFFFFFFFF,
      ...>        script_sig: <<0x76A914AFC3E518577316386188AF748A816CD14CE333F288AC::200>> |> BitcoinLib.Script.parse!()
      ...>      }
      ...>    ],
      ...>    outputs: [%BitcoinLib.Transaction.Output{
      ...>       script_pub_key: <<0x76a9283265393261373463333431393661303236653839653061643561633431386366393430613361663288ac::360>> |> BitcoinLib.Script.parse!(),
      ...>       value: 10_000}
      ...>    ],
      ...>    locktime: 0
      ...>  }
      ...>  |> BitcoinLib.Transaction.Signer.sign_and_encode(private_key)
      "0100000001b62ba991789fb1739e6a17b3891fd94cfebf09a61fedb203d619932a4326c2e4000000006a47304402207d2ff650acf4bd2f413dc04ded50fbbfc315bcb0aa97636b3c4caf55333d1c6a02207590f62363b2263b3d9b65dad3cd56e840e0d61dc0feab8f7e7956831c7e5103012102702ded1cca9816fa1a94787ffc6f3ace62cd3b63164f76d227d0935a33ee48c3ffffffff0110270000000000002d76a9283265393261373463333431393661303236653839653061643561633431386366393430613361663288ac00000000"
  """
  @spec sign_and_encode(%Transaction{}, %PrivateKey{}) :: binary()
  def sign_and_encode(%Transaction{} = transaction, %PrivateKey{} = private_key) do
    transaction_hex = Transaction.encode(transaction)

    public_key = PublicKey.from_private_key(private_key)

    hashed_preimage =
      transaction_hex
      |> append_sighash(1)
      |> Crypto.double_sha256()

    signature =
      hashed_preimage
      |> PrivateKey.sign_message(private_key)

    #    valid? =
    # signature
    # |> PublicKey.validate_signature(hashed_preimage, public_key)
    # |> IO.inspect(label: "is signature valid?")

    {_script_sig_length, script_sig} =
      Script.encode([
        %Opcodes.Data{value: <<signature::bitstring, 1>>},
        %Opcodes.Data{value: public_key.key}
      ])

    [old_input] = transaction.inputs
    new_input = %{old_input | script_sig: script_sig}

    transaction = %{transaction | inputs: [new_input]}

    # transaction
    # |> Map.get(:inputs)
    # |> List.first()
    # |> Map.get(:script_sig)
    # |> Binary.to_hex()
    # |> IO.inspect(limit: :infinity, label: "script sig")

    Transaction.encode(transaction)
    |> Binary.to_hex()
  end

  defp append_sighash(transaction, sighash) do
    <<transaction::bitstring, sighash::little-32>>
  end
end
