defmodule BitcoinLib.Signing.Psbt.Input.FinalScriptSig do
  defstruct [:script_sig]

  alias BitcoinLib.Signing.Psbt.Input.FinalScriptSig
  alias BitcoinLib.Signing.Psbt.Keypair.{Key}
  alias BitcoinLib.Script

  def parse(keypair) do
    %{keypair: keypair, final_script_sig: %FinalScriptSig{}}
    |> validate_keypair()
    |> extract_final_script_sig()
  end

  defp validate_keypair(%{keypair: keypair, final_script_sig: final_script_sig} = map) do
    case keypair.key do
      %Key{data: <<>>} ->
        map

      _ ->
        %{
          map
          | final_script_sig:
              Map.put(final_script_sig, :error, "invalid final script sig typed key")
        }
    end
  end

  defp extract_final_script_sig(%{final_script_sig: %{error: _message} = final_script_sig}),
    do: final_script_sig

  defp extract_final_script_sig(%{keypair: keypair}) do
    script = Script.parse(keypair.value.data)
    
    %FinalScriptSig{script_sig: script}
  end
end
