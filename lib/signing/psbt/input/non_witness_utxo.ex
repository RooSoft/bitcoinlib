defmodule BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo do
  defstruct [:transaction]

  alias BitcoinLib.Signing.Psbt.Input.NonWitnessUtxo
  alias BitcoinLib.Transaction

  def parse(remaining) do
    transaction = Transaction.decode(remaining)

    %NonWitnessUtxo{transaction: transaction}
  end
end
