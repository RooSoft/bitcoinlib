defmodule BitcoinLib.Transaction.Validator.Preimage do
  @moduledoc """
  Hashes a transaction right before the signing
  """

  alias BitcoinLib.Transaction
  alias BitcoinLib.Crypto

  @four_bytes 32

  def from_transaction(transaction, sighash_type) do
    transaction
    |> Transaction.encode()
    |> append_sighash_type(sighash_type)
    |> Crypto.double_sha256()
  end

  defp append_sighash_type(data, sighash_type),
    do: <<data::bitstring, sighash_type::little-@four_bytes>>
end
