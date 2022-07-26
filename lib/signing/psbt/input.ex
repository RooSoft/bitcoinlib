defmodule BitcoinLib.Signing.Psbt.Input do
  defstruct [:utxo, :witness?, unknowns: []]

  alias BitcoinLib.Signing.Psbt.{Keypair, KeypairList, Input}
  alias BitcoinLib.Signing.Psbt.Input.{NonWitnessUtxo, WitnessUtxo, PartialSig, RedeemScript}

  @non_witness_utxo 0
  @witness_utxo 1
  @partial_sig 2
  @redeem_script 4

  def from_keypair_list(%KeypairList{} = keypair_list) do
    keypair_list.keypairs
    |> Enum.reduce(%Input{}, &dispatch_keypair/2)
  end

  defp dispatch_keypair(%Keypair{key: key, value: value}, input) do
    case key.type do
      @non_witness_utxo -> add_non_witness_utxo(input, value)
      @witness_utxo -> add_witness_utxo(input, value)
      @partial_sig -> add_partial_sig(input, key.data, value)
      @redeem_script -> add_redeem_script(input, value)
      _ -> add_unknown(input, key, value)
    end
  end

  defp add_non_witness_utxo(input, value) do
    input
    |> Map.put(:utxo, NonWitnessUtxo.parse(value.data))
    |> Map.put(:witness?, false)
  end

  defp add_witness_utxo(input, value) do
    {witness_utxo, _remaining} = WitnessUtxo.parse(value.data)

    input
    |> Map.put(:utxo, witness_utxo)
    |> Map.put(:witness?, true)
  end

  defp add_partial_sig(input, key_value, value) do
    input
    |> Map.put(:partial_sig, PartialSig.parse(key_value, value.data))
  end

  defp add_redeem_script(input, value) do
    input
    |> Map.put(:redeem_script, RedeemScript.parse(value.data))
  end

  defp add_unknown(input, key, value) do
    input
    |> Map.put(:unknowns, [{key, value} | input.unknowns])
  end
end
