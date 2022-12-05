defmodule BitcoinLib.Transaction.Validator.ScriptSig do
  @moduledoc """
  Analyzes the script sig section of a transaction input in the process of validating
  that transaction
  """

  # alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.Input
  alias BitcoinLib.Script

  @byte 8

  # @spec from_transaction(%Transaction{}) :: {:ok, list()} | {:error, binary()}
  # def from_transaction(%Transaction{inputs: inputs}) do
  #   from_inputs(inputs)
  # end

  # @spec from_inputs(list(%Input{})) :: {:ok, list()} | {:error, binary()}
  # def from_inputs(inputs) do
  #   with {:ok, reversed_signatures} <- apply_extraction(inputs) do
  #     {:ok, Enum.reverse(reversed_signatures)}
  #   else
  #     {:error, message} -> {:error, message}
  #   end
  # end

  def p2pkh_from_input(%Input{script_sig: script_sig}) do
    with {:ok, [public_key, signature]} <- Script.execute(script_sig, []) do
      der_signature_size = bit_size(signature) - @byte

      <<der_signature::bitstring-size(der_signature_size), sighash_type::@byte>> = signature

      {:ok, %{der_signature: der_signature, sighash_type: sighash_type, public_key: public_key}}
    else
      {:error, message} -> {:error, message}
    end
  end

  # defp apply_extraction(inputs) do
  #   inputs
  #   |> Enum.map(&from_input/1)
  #   |> Enum.reduce({:ok, []}, &validate_signature/2)
  # end

  # defp validate_signature({:error, message}, _acc), do: {:error, message}

  # defp validate_signature({:ok, signature}, {:ok, signatures}) do
  #   {:ok, [signature | signatures]}
  # end
end
