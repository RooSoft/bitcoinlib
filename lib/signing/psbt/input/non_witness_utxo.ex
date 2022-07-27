defmodule BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo do
  defstruct [:transaction]

  alias BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo
  # alias BitcoinLib.Transaction

  def parse(remaining) do
    # IO.puts "----- PARSING NON-WITNESS UTXO"

    # transaction = Transaction.decode(remaining)

    # %NonWitnessUtxo{transaction: transaction}
    %NonWitnessUtxo{transaction: remaining}
  end
end
