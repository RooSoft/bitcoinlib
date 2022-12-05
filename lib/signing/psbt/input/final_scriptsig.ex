defmodule BitcoinLib.Signing.Psbt.Input.FinalScriptSig do
  @moduledoc """
  The final script signture in a partially signed bitcoin transaction's input
  """

  defstruct [:script_sig]

  alias BitcoinLib.Signing.Psbt.Input.FinalScriptSig
  alias BitcoinLib.Signing.Psbt.Keypair.{Key}
  alias BitcoinLib.Script

  # TODO: document
  def parse(keypair) do
    %{keypair: keypair}
    |> validate_keypair()
    |> extract_final_script_sig()
    |> create_output()
  end

  defp create_output(%{error: message}), do: {:error, message}
  defp create_output(%{final_script_sig: final_script_sig}), do: {:ok, final_script_sig}

  defp validate_keypair(%{keypair: keypair} = map) do
    case keypair.key do
      %Key{data: <<>>} ->
        map

      _ ->
        Map.put(map, :error, "invalid final script sig typed key")
    end
  end

  defp extract_final_script_sig(%{error: _message} = map), do: map

  defp extract_final_script_sig(%{keypair: keypair} = map) do
    case Script.parse(keypair.value.data) do
      {:ok, script} ->
        Map.put(map, :final_script_sig, %FinalScriptSig{script_sig: script})

      {:error, message} ->
        Map.put(map, :error, message)
    end
  end
end
