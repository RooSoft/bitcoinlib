defmodule BitcoinLib.Transaction.Validator do
  @moduledoc """
  Making sure transactions are valid
  """

  alias BitcoinLib.Console
  # alias BitcoinLib.Key.PublicKey
  alias BitcoinLib.Transaction
  # alias BitcoinLib.Transaction.{Input, Output}
  # alias BitcoinLib.Script
  alias BitcoinLib.Transaction.Validator.{Input, Preimage}
  alias BitcoinLib.Transaction.Validator.Input, as: ValidatorInput

  #  alias BitcoinLib.Console

  # ############ from signer, works right after creating the signature
  # valid? =
  #   signature
  #   |> PublicKey.validate_signature(hashed_preimage, public_key)
  #   |> IO.inspect(label: "is signature valid?")
  # ###########

  @doc """
  Validates a transaction

  ## Data from the signer's doctest
  # transaction before signing: <<0x0100000001b62ba991789fb1739e6a17b3891fd94cfebf09a61fedb203d619932a4326c2e4000000001976a914afc3e518577316386188af748a816cd14ce333f288acffffffff0110270000000000002d76a9283265393261373463333431393661303236653839653061643561633431386366393430613361663288ac00000000::1040>>
  # transaction after signing: <<0x0100000001b62ba991789fb1739e6a17b3891fd94cfebf09a61fedb203d619932a4326c2e4000000006a47304402207d2ff650acf4bd2f413dc04ded50fbbfc315bcb0aa97636b3c4caf55333d1c6a02207590f62363b2263b3d9b65dad3cd56e840e0d61dc0feab8f7e7956831c7e5103012102702ded1cca9816fa1a94787ffc6f3ace62cd3b63164f76d227d0935a33ee48c3ffffffff0110270000000000002d76a9283265393261373463333431393661303236653839653061643561633431386366393430613361663288ac00000000::1688>>
  # public_key: <<0x02702ded1cca9816fa1a94787ffc6f3ace62cd3b63164f76d227d0935a33ee48c3::264>>
  # signature: <<0x304402207d2ff650acf4bd2f413dc04ded50fbbfc315bcb0aa97636b3c4caf55333d1c6a02207590f62363b2263b3d9b65dad3cd56e840e0d61dc0feab8f7e7956831c7e5103::560>>
  # sighash_type: 1
  # preimage: <<0xee564327e1868240a2bbe3d3b445ac946a396de9802ede1ecaff0024f77eeca3::256>>

  #### STEPS
  # √ 1- decode transaction
  # √ 2- extract signature
  # √ 3- recreate preimage
  #   4- validate input

  ## Examples
      iex>  "0100000001b62ba991789fb1739e6a17b3891fd94cfebf09a61fedb203d619932a4326c2e4000000006a47304402207d2ff650acf4bd2f413dc04ded50fbbfc315bcb0aa97636b3c4caf55333d1c6a02207590f62363b2263b3d9b65dad3cd56e840e0d61dc0feab8f7e7956831c7e5103012102702ded1cca9816fa1a94787ffc6f3ace62cd3b63164f76d227d0935a33ee48c3ffffffff0110270000000000002d76a9283265393261373463333431393661303236653839653061643561633431386366393430613361663288ac00000000"
      ...>  |> BitcoinLib.Transaction.Validator.verify(prevouts, public_key)
      true
  """
  @spec verify(binary(), (binary() -> %Transaction{})) :: boolean()
  def verify(txid, get_transaction_by_id) do
    IO.inspect(txid)

    with {:ok, %Transaction{inputs: inputs} = transaction} <- get_transaction_by_id.(txid) do
      [{:ok, validator_input}] =
        inputs
        |> Enum.map(&Input.validate(&1, get_transaction_by_id))
        |> IO.inspect(label: "INPUT VALIDATION RESULTS")

      add_preimages(validator_input, transaction)

      #         {:ok, prevouts} <- Prevout.from_transaction(transaction, get_transaction_by_id) do
      ## {:ok, signatures} <- Signatures.from_transaction(transaction)
      ## [%{der_signature: der_signature, sighash_type: sighash_type}] = signatures
      ## preimage = Preimage.from_transaction(transaction, sighash_type)

      #      IO.inspect(prevouts, label: "prevouts")
      ## Console.print_hex(der_signature, "der_signature")
      ## Console.print_hex(preimage, "preimage")
    else
      {:error, message} ->
        IO.inspect("an error occured: #{message}")
        {:error, message}
    end

    # signatures = get_signatures(transaction)

    # Enum.zip_with(signatures, prevouts, &merge_signatures_and_prevouts/2)
    # |> preimage(transaction)

    true
  end

  def add_preimages(
        %ValidatorInput{type: _type, der_signature: _der_signature, sighash_type: sighash_type},
        %Transaction{} = transaction
      ) do
    IO.inspect(transaction, limit: :infinity)

    preimage = Preimage.from_transaction(transaction, sighash_type)

    Console.print_hex(preimage, "preimage")
  end
end
