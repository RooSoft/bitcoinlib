defmodule BitcoinLib.Signing.Psbt.GenericProperties.WitnessScript do
  defstruct [:script]

  alias BitcoinLib.Signing.Psbt.GenericProperties.WitnessScript
  alias BitcoinLib.Signing.Psbt.Keypair.{Key}
  alias BitcoinLib.Script

  def parse(keypair) do
    %{keypair: keypair, witness_script: %WitnessScript{}}
    |> validate_keypair()
    |> extract_witness_script()
  end

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

  defp extract_witness_script(%{keypair: keypair}) do
    script =
      keypair.value.data
      |> Script.parse()

    %WitnessScript{script: script}
  end
end
