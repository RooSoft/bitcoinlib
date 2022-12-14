defmodule BitcoinLib.Transaction.BetterSigner.Inputs do
  alias BitcoinLib.Transaction
  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.{PrivateKey, PublicKey}

  @sighash_all 1
  # @byte 8
  @four_bytes 32

  def sign(transaction, private_keys) do
    private_keys
    |> Enum.with_index()
    |> Enum.map(&get_signature(&1, transaction))
  end

  defp get_signature({private_key, input_index}, transaction) do
    input_to_sign = Enum.at(transaction.inputs, input_index)

    transaction
    |> Transaction.strip_signatures(except: input_to_sign)
    |> create_preimage(@sighash_all)
    |> create_signature(private_key)
  end

  defp create_preimage(transaction, sighash_type) do
    transaction
    |> Transaction.encode()
    |> append_sighash(sighash_type)
    |> Crypto.double_sha256()
  end

  defp create_signature(preimage, private_key), do: PrivateKey.sign_message(preimage, private_key)

  # defp sign_input(signature, transaction, public_key, sighash_type) do
  #   script_sig =
  #     signature
  #     |> create_script_sig(public_key, sighash_type)

  #   [old_input] = transaction.inputs
  #   new_input = %{old_input | script_sig: script_sig}

  #   %{transaction | inputs: [new_input]}
  # end

  # defp create_script_sig(signature, public_key, sighash_type) do
  #   Script.encode([
  #     %Opcodes.Data{value: <<signature::bitstring, sighash_type::@byte>>},
  #     %Opcodes.Data{value: public_key.key}
  #   ])
  #   |> elem(1)
  # end

  defp append_sighash(transaction, sighash),
    do: <<transaction::bitstring, sighash::little-@four_bytes>>
end
