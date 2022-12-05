defmodule BitcoinLib.Transaction.Spec.Input do
  @moduledoc """
  A simplified version of a %BitcoinLib.Transaction.Input that can be filled with human readable formats
  """
  defstruct [:txid, :vout, :redeem_script, sequence: 0xFFFFFFFD]

  alias BitcoinLib.Transaction.Spec
  alias BitcoinLib.Transaction
  alias BitcoinLib.Transaction.Spec.Input

  @type t :: Input

  @doc """
  Converts a human readable input into a %Transaction.Input{}

  ## Examples
      iex> %BitcoinLib.Transaction.Spec.Input{
      ...>   txid: "6925062befcf8aafae78de879fec2535ec016e251c19b1c0792993258a6fda26",
      ...>   vout: 1,
      ...>   redeem_script: "76a914c39658833d83f2299416e697af2fb95a998853d388ac"
      ...> }
      ...> |> BitcoinLib.Transaction.Spec.Input.to_transaction_input()
      %BitcoinLib.Transaction.Input{
        txid: "6925062befcf8aafae78de879fec2535ec016e251c19b1c0792993258a6fda26",
        vout: 1,
        sequence: 4294967293,
        script_sig: "76a914c39658833d83f2299416e697af2fb95a998853d388ac"
      }
  """
  @spec to_transaction_input(Spec.Input.t()) :: Transaction.Input.t()
  def to_transaction_input(%Spec.Input{
        txid: txid,
        vout: vout,
        redeem_script: redeem_script,
        sequence: sequence
      }) do
    %Transaction.Input{
      txid: txid,
      vout: vout,
      sequence: sequence,
      script_sig: redeem_script
    }
  end
end
