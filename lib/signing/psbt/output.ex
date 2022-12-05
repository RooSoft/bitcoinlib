defmodule BitcoinLib.Signing.Psbt.Output do
  @moduledoc """
  An output in a partially signed bitcoin transaction
  """

  defstruct unknowns: []

  alias BitcoinLib.Signing.Psbt.{Keypair, KeypairList, Output}

  alias BitcoinLib.Signing.Psbt.GenericProperties.{
    Bip32Derivation,
    Proprietary,
    RedeemScript,
    WitnessScript
  }

  @redeem_script 0x0
  @witness_script 0x1
  @bip32_derivation 0x2
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
    |> Enum.reduce(%Output{}, &dispatch_keypair/2)
  end

  defp dispatch_keypair(%Keypair{key: key} = keypair, output) do
    case key.type do
      @redeem_script -> add_redeem_script(output, keypair)
      @witness_script -> add_witness_script(output, keypair)
      @bip32_derivation -> add_bip32_derivation(output, keypair)
      @proprietary -> add_proprietary(output, keypair)
      _ -> add_unknown(output, keypair)
    end
  end

  defp add_redeem_script(output, keypair) do
    case RedeemScript.parse(keypair) do
      {:ok, redeem_script} ->
        output
        |> Map.put(:redeem_script, redeem_script)

      {:error, message} ->
        output
        |> Map.put(:error, message)
    end
  end

  defp add_witness_script(output, keypair) do
    case WitnessScript.parse(keypair) do
      {:ok, witness_script} ->
        output
        |> Map.put(:witness_script, witness_script.script)

      {:error, message} ->
        output
        |> Map.put(:error, message)
    end
  end

  defp add_bip32_derivation(output, keypair) do
    bip32_derivation = Bip32Derivation.parse(keypair)

    case Map.get(bip32_derivation, :error) do
      nil ->
        output
        |> Map.put(:bip32_derivation, bip32_derivation)

      message ->
        output
        |> Map.put(:error, message)
    end
  end

  defp add_proprietary(%{error: _message} = output, _keypair), do: output

  defp add_proprietary(output, keypair) do
    output
    |> Map.put(:proprietary, Proprietary.parse(keypair))
  end

  defp add_unknown(output, keypair) do
    output
    |> Map.put(:unknowns, [keypair | output.unknowns])
  end
end
