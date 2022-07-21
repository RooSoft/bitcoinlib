defmodule BitcoinLib.Signing.Psbt.Global do
  defstruct [:unsigned_tx, tx_version: 0, unknowns: []]

  alias BitcoinLib.Signing.Psbt.{Keypair, KeypairList, Global}
  alias BitcoinLib.Transaction

  @unsigned_tx 0
  @tx_version 2

  def from_keypair_list(%KeypairList{} = keypair_list) do
    keypair_list.keypairs
    |> Enum.reduce(%Global{}, &dispatch_keypair/2)
  end

  defp dispatch_keypair(%Keypair{key: key, value: value}, input) do
    case key.type do
      @unsigned_tx -> add_unsigned_tx(input, value)
      @tx_version -> add_tx_version(input, value)
      _ -> add_unknown(input, key, value)
    end
  end

  defp add_unsigned_tx(input, value) do
    unsigned_tx = Transaction.decode(value.data)

    input
    |> Map.put(:unsigned_tx, unsigned_tx)
  end

  defp add_tx_version(input, value) do
    input
    |> Map.put(:tx_version, value.data)
  end

  defp add_unknown(input, key, value) do
    input
    |> Map.put(:unknowns, [{key, value} | input.unknowns])
  end
end
