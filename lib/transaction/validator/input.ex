defmodule BitcoinLib.Transaction.Validator.Input do
  alias BitcoinLib.Crypto
  alias BitcoinLib.Script
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.{Input}
  alias BitcoinLib.Transaction.Validator.{Prevout, ScriptSig}
  alias BitcoinLib.Transaction.Validator.Input, as: ValidatorInput

  require Logger

  defstruct [:type, :der_signature, :sighash_type]

  @spec validate(%Input{}, (binary() -> %Transaction{})) :: {:ok, boolean()} | {:error, binary()}
  def validate(%Input{} = input, get_transaction_by_id) do
    with {:ok, output} <- Prevout.from_input(input, get_transaction_by_id) do
      case Script.identify(output.script_pub_key) do
        {:p2pkh, public_key_hash} ->
          validate_p2pkh(input, public_key_hash)

        other ->
          Logger.warning(inspect(other, label: "unknown prevout script type"))
          false
      end
    end
  end

  defp validate_p2pkh(input, public_key_hash) do
    with {:ok,
          %{public_key: public_key, der_signature: der_signature, sighash_type: sighash_type}} <-
           ScriptSig.p2pkh_from_input(input) do
      if public_key |> Crypto.hash160() == public_key_hash do
        {
          :ok,
          %ValidatorInput{type: :p2pkh, der_signature: der_signature, sighash_type: sighash_type}
        }
      else
        {:error, "public key and public key hash don't match"}
      end
    else
      {:error, message} -> {:error, message}
    end
  end
end
