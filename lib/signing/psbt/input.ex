defmodule BitcoinLib.Signing.Psbt.Input do
  defstruct [
    :utxo,
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
    FinalScriptWitness,
    ProofOfReservesCommitment,
    Ripemd160Preimage,
    Sha256Preimage,
    OutputIndex
  }

  @non_witness_utxo 0x0
  @witness_utxo 0x1
  @partial_sig 0x2
  @sighash_type 0x3
  @redeem_script 0x4
  @witness_script 0x5
  @bip32_derivation 0x6
  @final_script_sig 0x7
  @final_script_witness 0x8
  @proof_of_reserves_commitment 0x9
  @ripemd160_preimage 0xA
  @sha256_preimage 0xB
  @output_index 0xF

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
      @proof_of_reserves_commitment -> add_proof_of_reserves_commitment(input, keypair)
      @ripemd160_preimage -> add_ripemd160_preimage(input, keypair)
      @sha256_preimage -> add_sha256_preimage(input, keypair)
      @output_index -> add_output_index(input, keypair)
      _ -> add_unknown(input, keypair)
    end
  end

  defp add_non_witness_utxo(input, keypair) do
    utxo = NonWitnessUtxo.parse(keypair)

    case Map.get(utxo, :error) do
      nil ->
        input
        |> Map.put(:utxo, utxo)

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
    sighash_type = SighashType.parse(value.data)

    case sighash_type do
      %SighashType{} ->
        input
        |> Map.put(:sighash_type, sighash_type)

      %{error: message} ->
        input |> Map.put(:error, message)
    end
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

  defp add_proof_of_reserves_commitment(input, keypair) do
    proof_of_reserves_commitment = ProofOfReservesCommitment.parse(keypair)

    input
    |> Map.put(:proof_of_reserves_commitment, proof_of_reserves_commitment)
  end

  defp add_ripemd160_preimage(input, keypair) do
    ripemd160_preimage = Ripemd160Preimage.parse(keypair.key, keypair.value)

    case Map.get(ripemd160_preimage, :error) do
      nil ->
        input
        |> Map.put(:ripemd160_preimage, ripemd160_preimage)

      message ->
        input
        |> Map.put(:error, message)
    end
  end

  defp add_sha256_preimage(input, keypair) do
    sha256_preimage = Sha256Preimage.parse(keypair.key, keypair.value)

    case Map.get(sha256_preimage, :error) do
      nil ->
        input
        |> Map.put(:sha256_preimage, sha256_preimage)

      message ->
        input
        |> Map.put(:error, message)
    end
  end

  defp add_output_index(input, keypair) do
    output_index = OutputIndex.parse(keypair)

    case Map.get(output_index, :error) do
      nil ->
        input
        |> Map.put(:output_index, output_index)

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
