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

  alias BitcoinLib.Signing.Psbt.GenericProperties.{
    Bip32Derivation,
    Proprietary,
    RedeemScript,
    WitnessScript
  }

  alias BitcoinLib.Signing.Psbt.Input.{
    NonWitnessUtxo,
    WitnessUtxo,
    PartialSig,
    SighashType,
    FinalScriptSig,
    FinalScriptWitness,
    ProofOfReservesCommitment,
    Ripemd160Preimage,
    Sha256Preimage,
    Hash160Preimage,
    Hash256Preimage,
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
  @hash160_preimage 0xC
  @hash256_preimage 0xD
  @output_index 0xF
  @proprietary 0xFC

  # TODO: document
  def from_keypair_list(nil) do
    nil
  end

  # TODO: document
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
      @bip32_derivation -> add_bip32_derivation(input, keypair)
      @final_script_sig -> add_final_script_sig(input, keypair)
      @final_script_witness -> add_final_script_witness(input, keypair)
      @proof_of_reserves_commitment -> add_proof_of_reserves_commitment(input, keypair)
      @ripemd160_preimage -> add_ripemd160_preimage(input, keypair)
      @sha256_preimage -> add_sha256_preimage(input, keypair)
      @hash160_preimage -> add_hash160_preimage(input, keypair)
      @hash256_preimage -> add_hash256_preimage(input, keypair)
      @output_index -> add_output_index(input, keypair)
      @proprietary -> add_proprietary(input, keypair)
      _ -> add_unknown(input, keypair)
    end
  end

  defp add_non_witness_utxo(input, keypair) do
    case NonWitnessUtxo.parse(keypair) do
      {:ok, utxo} ->
        input
        |> Map.put(:utxo, utxo)

      {:error, message} ->
        input
        |> Map.put(:error, message)
    end
  end

  defp add_witness_utxo(input, keypair) do
    case WitnessUtxo.parse(keypair) do
      {:ok, utxo} ->
        input
        |> Map.put(:utxo, utxo)

      {:error, message} ->
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
        |> Map.put(:sighash_type, sighash_type.value)

      %{error: message} ->
        input |> Map.put(:error, message)
    end
  end

  defp add_redeem_script(input, keypair) do
    case RedeemScript.parse(keypair) do
      {:ok, redeem_script} -> input |> Map.put(:redeem_script, redeem_script.script)
      {:error, message} -> input |> Map.put(:error, message)
    end
  end

  defp add_witness_script(input, keypair) do
    case WitnessScript.parse(keypair) do
      {:ok, witness_script} -> input |> Map.put(:witness_script, witness_script.script)
      {:error, message} -> input |> Map.put(:error, message)
    end
  end

  defp add_bip32_derivation(%{bip32_derivations: derivations} = input, keypair) do
    derivation = Bip32Derivation.parse(keypair)

    case Map.get(derivation, :error) do
      nil ->
        input
        |> Map.put(:bip32_derivations, [derivation | derivations])

      message ->
        input |> Map.put(:error, message)
    end
  end

  defp add_final_script_sig(input, keypair) do
    case FinalScriptSig.parse(keypair) do
      {:ok, final_script_sig} ->
        input
        |> Map.put(:final_script_sig, final_script_sig.script_sig)

      {:error, message} ->
        input
        |> Map.put(:error, message)
    end
  end

  defp add_final_script_witness(input, keypair) do
    final_script_witness = FinalScriptWitness.parse(keypair)

    case Map.get(final_script_witness, :error) do
      nil ->
        input
        |> Map.put(:final_script_witness, final_script_witness.script_witness)

      message ->
        input
        |> Map.put(:error, message)
    end
  end

  defp add_proof_of_reserves_commitment(input, keypair) do
    proof_of_reserves_commitment = ProofOfReservesCommitment.parse(keypair)

    input
    |> Map.put(:proof_of_reserves_commitment, proof_of_reserves_commitment.value)
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

  defp add_hash160_preimage(input, keypair) do
    hash160_preimage = Hash160Preimage.parse(keypair.key, keypair.value)

    case Map.get(hash160_preimage, :error) do
      nil ->
        input
        |> Map.put(:hash160_preimage, hash160_preimage)

      message ->
        input
        |> Map.put(:error, message)
    end
  end

  defp add_hash256_preimage(input, keypair) do
    hash256_preimage = Hash256Preimage.parse(keypair.key, keypair.value)

    case Map.get(hash256_preimage, :error) do
      nil ->
        input
        |> Map.put(:hash256_preimage, hash256_preimage)

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

  defp add_proprietary(%{error: _message} = input, _keypair), do: input

  defp add_proprietary(input, keypair) do
    input
    |> Map.put(:proprietary, Proprietary.parse(keypair))
  end

  defp add_unknown(input, keypair) do
    input
    |> Map.put(:unknowns, [keypair | input.unknowns])
  end
end
