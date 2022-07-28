defmodule BitcoinLib.Signing.Psbt.Input do
  defstruct [
    :utxo,
    :witness?,
    :partial_sig,
    :sighash_type,
    :redeem_script,
    :witness_script,
    :final_script_sig,
    bip32_derivations: [],
    unknowns: []
  ]

  alias BitcoinLib.Signing.Psbt.{Keypair, KeypairList, Input}

  alias BitcoinLib.Signing.Psbt.Input.{
    NonWitnessUtxo,
    WitnessUtxo,
    PartialSig,
    SighashType,
    RedeemScript,
    WitnessScript,
    Bip32Derivation,
    FinalScriptSig
  }

  @non_witness_utxo 0
  @witness_utxo 1
  @partial_sig 2
  @sighash_type 3
  @redeem_script 4
  @witness_script 5
  @bip32_derivation 6
  @final_script_sig 7

  def from_keypair_list(nil) do
    nil
  end

  def from_keypair_list(%KeypairList{} = keypair_list) do
    keypair_list.keypairs
    |> validate_keys
    |> dispatch_keypairs
  end

  defp validate_keys(keypairs) do
    keys =
      keypairs
      |> Enum.map(& &1.key)

    duplicate_keys = keys -- Enum.uniq(keys)

    case duplicate_keys do
      [] ->
        {:ok, keypairs}

      duplicates ->
        {:error, "duplicate keys: #{inspect(duplicates)}"}
    end
  end

  defp dispatch_keypairs({:error, message}) do
    {:error, message}
  end

  defp dispatch_keypairs({:ok, keypairs}) do
    inputs =
      keypairs
      |> Enum.reduce(%Input{}, &dispatch_keypair/2)

    {:ok, inputs}
  end

  defp dispatch_keypair(%Keypair{key: key, value: value} = keypair, input) do
    case key.type do
      @non_witness_utxo -> add_non_witness_utxo(input, value)
      @witness_utxo -> add_witness_utxo(input, value)
      @partial_sig -> add_partial_sig(input, key.data, value)
      @sighash_type -> add_sighash_type(input, value)
      @redeem_script -> add_redeem_script(input, value)
      @witness_script -> add_witness_script(input, value)
      @bip32_derivation -> add_bip32_derivation(input, key.data, value)
      @final_script_sig -> add_final_script_sig(input, value)
      _ -> add_unknown(input, keypair)
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

  defp add_sighash_type(input, value) do
    input
    |> Map.put(:sighash_type, SighashType.parse(value.data))
  end

  defp add_redeem_script(input, value) do
    input
    |> Map.put(:redeem_script, RedeemScript.parse(value.data))
  end

  defp add_witness_script(input, value) do
    input
    |> Map.put(:witness_script, WitnessScript.parse(value.data))
  end

  defp add_bip32_derivation(%{bip32_derivations: derivations} = input, key_value, value) do
    derivation = Bip32Derivation.parse(key_value, value.data)

    input
    |> Map.put(:bip32_derivations, [derivation | derivations])
  end

  defp add_final_script_sig(input, value) do
    input
    |> Map.put(:final_script_sig, FinalScriptSig.parse(value.data))
  end

  defp add_unknown(input, keypair) do
    input
    |> Map.put(:unknowns, [keypair | input.unknowns])
  end
end
