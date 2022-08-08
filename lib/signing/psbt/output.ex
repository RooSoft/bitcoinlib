defmodule BitcoinLib.Signing.Psbt.Output do
  defstruct unknowns: []

  alias BitcoinLib.Signing.Psbt.{Keypair, KeypairList, Output}
  alias BitcoinLib.Signing.Psbt.Output.{RedeemScript, Bip32Derivation}

  @redeem_script 0
  @bip32_derivation 2

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
    |> Enum.reduce(%Output{}, &dispatch_keypair/2)
  end

  defp dispatch_keypair(%Keypair{key: key, value: value} = keypair, output) do
    case key.type do
      @redeem_script -> add_redeem_script(output, keypair)
      @bip32_derivation -> add_bip32_derivation(output, keypair)
      _ -> add_unknown(output, key, value)
    end
  end

  defp add_redeem_script(output, keypair) do
    redeem_script = RedeemScript.parse(keypair)

    case Map.get(redeem_script, :error) do
      nil ->
        output
        |> Map.put(:redeem_script, redeem_script)

      message ->
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

  defp add_unknown(input, key, value) do
    input
    |> Map.put(:unknowns, [{key, value} | input.unknowns])
  end
end
