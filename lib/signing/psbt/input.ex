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
    FinalScriptSig,
    FinalScriptWitness
  }

  @non_witness_utxo 0
  @witness_utxo 1
  @partial_sig 2
  @sighash_type 3
  @redeem_script 4
  @witness_script 5
  @bip32_derivation 6
  @final_script_sig 7
  @final_script_witness 8

  def from_keypair_list(nil) do
    nil
  end

  def from_keypair_list(%KeypairList{} = keypair_list) do
    result =
      keypair_list.keypairs
      |> validate_keys
      |> dispatch_keypairs

    case result do
      {:error, message} ->
        {:error, message}

      _ ->
        result
    end
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
    %{error: message}
  end

  defp dispatch_keypairs({:ok, keypairs}) do
    keypairs
    |> Enum.reduce(%Input{}, &dispatch_keypair/2)
  end

  defp dispatch_keypair(%Keypair{key: key, value: value} = keypair, input) do
    case key.type do
      @non_witness_utxo -> add_non_witness_utxo(input, keypair)
      @witness_utxo -> add_witness_utxo(input, keypair)
      @partial_sig -> add_partial_sig(input, key.data, value)
      @sighash_type -> add_sighash_type(input, value)
      @redeem_script -> add_redeem_script(input, keypair)
      @witness_script -> add_witness_script(input, keypair)
      @bip32_derivation -> add_bip32_derivation(input, key.data, value)
      @final_script_sig -> add_final_script_sig(input, keypair)
      @final_script_witness -> add_final_script_witness(input, keypair)
      _ -> add_unknown(input, keypair)
    end
  end

  defp add_non_witness_utxo(input, keypair) do
    utxo = NonWitnessUtxo.parse(keypair)

    case Map.get(utxo, :error) do
      nil ->
        input
        |> Map.put(:utxo, utxo)
        |> Map.put(:witness?, false)

      message ->
        input
        |> Map.put(:error, message)
    end
  end

  defp add_witness_utxo(input, keypair) do
    utxo = WitnessUtxo.parse(keypair)

    case Map.get(utxo, :error) do
      nil ->
        input
        |> Map.put(:utxo, utxo)
        |> Map.put(:witness?, true)

      message ->
        input
        |> Map.put(:error, message)
    end
  end

  defp add_partial_sig(input, key_value, value) do
    partial_sig = PartialSig.parse(key_value, value.data)

    case Map.get(partial_sig, :error) do
      nil -> input |> Map.put(:partial_sig, partial_sig)
      message -> input |> Map.put(:error, message)
    end
  end

  defp add_sighash_type(input, value) do
    input
    |> Map.put(:sighash_type, SighashType.parse(value.data))
  end

  defp add_redeem_script(input, keypair) do
    redeem_script = RedeemScript.parse(keypair)

    case Map.get(redeem_script, :error) do
      nil -> input |> Map.put(:redeem_script, redeem_script)
      message -> input |> Map.put(:error, message)
    end
  end

  defp add_witness_script(input, keypair) do
    witness_script = WitnessScript.parse(keypair)

    case Map.get(witness_script, :error) do
      nil -> input |> Map.put(:witness_script, witness_script)
      message -> input |> Map.put(:error, message)
    end
  end

  defp add_bip32_derivation(%{bip32_derivations: derivations} = input, key_value, value) do
    derivation = Bip32Derivation.parse(key_value, value.data)

    case Map.get(derivation, :error) do
      nil ->
        input
        |> Map.put(:bip32_derivations, [derivation | derivations])

      message ->
        input |> Map.put(:error, message)
    end
  end

  defp add_final_script_sig(input, keypair) do
    final_script_sig = FinalScriptSig.parse(keypair)

    case Map.get(final_script_sig, :error) do
      nil ->
        input
        |> Map.put(:final_script_sig, final_script_sig)

      message ->
        input
        |> Map.put(:error, message)
    end
  end

  defp add_final_script_witness(input, keypair) do
    final_script_witness = FinalScriptWitness.parse(keypair)

    case Map.get(final_script_witness, :error) do
      nil ->
        input
        |> Map.put(:final_script_witness, final_script_witness)

      message ->
        input
        |> Map.put(:error, message)
    end
  end

  defp add_unknown(input, keypair) do
    input
    |> Map.put(:unknowns, [keypair | input.unknowns])
  end
end
