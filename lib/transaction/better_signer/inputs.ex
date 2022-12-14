defmodule BitcoinLib.Transaction.BetterSigner.Inputs do
  alias BitcoinLib.Transaction
  alias BitcoinLib.Crypto
  alias BitcoinLib.Key.{PrivateKey, PublicKey}
  alias BitcoinLib.Script
  alias BitcoinLib.Script.Opcodes

  @sighash_all 1
  @byte 8
  @four_bytes 32

  def sign(transaction, private_keys) do
    signature_results =
      private_keys
      |> Enum.with_index()
      |> Enum.map(fn {private_key, input_index} ->
        sign_input(private_key, input_index, transaction)
      end)

    with {:ok, signed_inputs} <- validate_results(signature_results) do
      %{transaction | inputs: signed_inputs}
    else
      {:error, message} -> {:error, message}
    end
  end

  defp validate_results(signature_results) do
    all_ok? =
      signature_results
      |> Enum.all?(fn {status, _} ->
        status == :ok
      end)

    if all_ok?,
      do: {:ok, signature_results |> Enum.map(fn {_, input} -> input end)},
      ## in case of error, will need to specifiy which input, and return a meaningful message
      else: {:error, "one signature has failed"}
  end

  defp sign_input(private_key, input_index, transaction) do
    input_to_sign = Enum.at(transaction.inputs, input_index)

    with public_key <- PublicKey.from_private_key(private_key) do
      signed_input =
        transaction
        |> Transaction.strip_signatures(except: input_to_sign)
        |> create_preimage(@sighash_all)
        |> create_signature(private_key)
        |> sign_input(input_to_sign, public_key, @sighash_all)

      {:ok, signed_input}
    else
      {:error, message} -> {:error, message}
    end
  end

  defp create_preimage(transaction, sighash_type) do
    transaction
    |> Transaction.encode()
    |> append_sighash(sighash_type)
    |> Crypto.double_sha256()
  end

  defp create_signature(preimage, private_key), do: PrivateKey.sign_message(preimage, private_key)

  defp sign_input(signature, input_to_sign, public_key, sighash_type) do
    script_sig =
      signature
      |> create_script_sig(public_key, sighash_type)

    %{input_to_sign | script_sig: script_sig}
  end

  defp create_script_sig(signature, public_key, sighash_type) do
    Script.encode([
      %Opcodes.Data{value: <<signature::bitstring, sighash_type::@byte>>},
      %Opcodes.Data{value: public_key.key}
    ])
    |> elem(1)
  end

  defp append_sighash(transaction, sighash),
    do: <<transaction::bitstring, sighash::little-@four_bytes>>
end
