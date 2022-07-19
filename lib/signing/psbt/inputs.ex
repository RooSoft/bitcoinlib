defmodule BitcoinLib.Signing.Psbt.Inputs do
  defstruct [:non_witness_utxo, unknowns: []]

  alias BitcoinLib.Signing.Psbt.{Keypair, KeypairList, Inputs}

  @non_witness_utxo 0

  def from_keypair_list(%KeypairList{} = keypair_list) do
    keypair_list.keypairs
    |> Enum.reduce(%Inputs{}, &dispatch_keypair/2)
  end

  defp dispatch_keypair(%Keypair{key: key, value: value}, input) do
    case key.keytype do
      @non_witness_utxo -> add_non_witness_utxo(input, value)
      _ -> add_unknown(input, key, value)
    end
  end

  defp add_non_witness_utxo(input, value) do
    input
    |> Map.put(:non_witness_utxo, value.valuedata)
  end

  defp add_unknown(input, key, value) do
    input
    |> Map.put(:unknowns, [{key, value} | input.unknowns])
  end
end
