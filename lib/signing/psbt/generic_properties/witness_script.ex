defmodule BitcoinLib.Signing.Psbt.GenericProperties.WitnessScript do
  defstruct [:script]

  alias BitcoinLib.Signing.Psbt.GenericProperties.WitnessScript
  alias BitcoinLib.Signing.Psbt.Keypair
  alias BitcoinLib.Signing.Psbt.Keypair.{Key}
  alias BitcoinLib.Script

  @spec parse(%Keypair{}) :: {:ok, %WitnessScript{}} | {:error, binary()}
  def parse(keypair) do
    %{keypair: keypair, witness_script: %WitnessScript{}}
    |> validate_keypair()
    |> extract_witness_script()
    |> create_output
  end

  defp create_output(%{error: message}), do: {:error, message}
  defp create_output(%{witness_script: witness_script}), do: {:ok, witness_script}

  defp validate_keypair(%{keypair: keypair, witness_script: witness_script} = map) do
    case keypair.key do
      %Key{data: <<>>} ->
        map

      _ ->
        %{
          map
          | witness_script: Map.put(witness_script, :error, "invalid witnessscript typed key")
        }
    end
  end

  defp extract_witness_script(%{witness_script: %{error: _message} = witness_script}),
    do: witness_script

  defp extract_witness_script(%{keypair: keypair} = map) do
    case Script.parse(keypair.value.data) do
      {:ok, script} ->
        Map.put(map, :witness_script, %WitnessScript{script: script})

      {:error, message} ->
        Map.put(map, :error, message)
    end
  end
end
