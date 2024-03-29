defmodule BitcoinLib.Transaction.Signer do
  @moduledoc """
  Signs transactions
  """

  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Transaction
  alias BitcoinLib.Script
  alias BitcoinLib.Script.Opcodes

  @sighash_all 1
  @byte 8
  @four_bytes 32

  @doc """
  Takes a transaction and signs it with the private key that's in the second parameter

  ## Examples
      testnet transaction id: 838935b6bf2a16966fe261f23f28a88482f3b3d24c9847b68a56abe90d41ca97

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
      ...>  |> BitcoinLib.Transaction.Signer.sign(private_key)
      ...>  |> Map.get(:inputs)
      [
        %BitcoinLib.Transaction.Input{
          txid: "e4c226432a9319d603b2ed1fa609bffe4cd91f89b3176a9e73b19f7891a92bb6",
          vout: 0,
          script_sig: <<0x47304402207d2ff650acf4bd2f413dc04ded50fbbfc315bcb0aa97636b3c4caf55333d1c6a02207590f62363b2263b3d9b65dad3cd56e840e0d61dc0feab8f7e7956831c7e5103012102702ded1cca9816fa1a94787ffc6f3ace62cd3b63164f76d227d0935a33ee48c3::848>>,
          sequence: 4294967295
        }
      ]
  """
  @spec sign(Transaction.t(), PrivateKey.t()) :: Transaction.t()
  def sign(%Transaction{} = transaction, %PrivateKey{} = private_key) do
    with public_key <- PublicKey.from_private_key(private_key) do
      transaction
      |> create_preimage(@sighash_all)
      |> create_signature(private_key)
      |> sign_input(transaction, public_key, @sighash_all)
    end
  end

  defp create_preimage(transaction, sighash_type) do
    transaction
    |> Transaction.encode()
    |> append_sighash(sighash_type)
    |> Crypto.double_sha256()
  end

  defp create_signature(preimage, private_key), do: PrivateKey.sign_message(preimage, private_key)

  defp sign_input(signature, transaction, public_key, sighash_type) do
    script_sig =
      signature
      |> create_script_sig(public_key, sighash_type)

    [old_input] = transaction.inputs
    new_input = %{old_input | script_sig: script_sig}

    %{transaction | inputs: [new_input]}
  end

  defp create_script_sig(signature, public_key, sighash_type) do
    Script.encode([
      %Opcodes.Data{value: <<signature::bitstring, sighash_type::@byte>>},
      %Opcodes.Data{value: public_key.key}
    ])
    |> elem(1)
  end

  defp append_sighash(transaction, sighash) do
    <<transaction::bitstring, sighash::little-@four_bytes>>
  end
end
