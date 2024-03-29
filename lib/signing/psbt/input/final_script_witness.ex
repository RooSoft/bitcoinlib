defmodule BitcoinLib.Signing.Psbt.Input.FinalScriptWitness do
  @moduledoc """
  The final script witness of a partially signed bitcoin transaction's input
  """

  defstruct [:script_witness]

  alias BitcoinLib.Signing.Psbt.Input.FinalScriptWitness
  alias BitcoinLib.Signing.Psbt.Keypair.{Key}

  # TODO: document
  def parse(keypair) do
    %{keypair: keypair, final_script_witness: %FinalScriptWitness{}}
    |> validate_keypair()
    |> extract_final_script_witness()
  end

  defp validate_keypair(%{keypair: keypair, final_script_witness: final_script_witness} = map) do
    case keypair.key do
      %Key{data: <<>>} ->
        map

      _ ->
        %{
          map
          | final_script_witness:
              Map.put(final_script_witness, :error, "invalid final script witness typed key")
        }
    end
  end

  defp extract_final_script_witness(%{
         final_script_witness: %{error: _message} = final_script_witness
       }),
       do: final_script_witness

  defp extract_final_script_witness(%{keypair: keypair}) do
    %FinalScriptWitness{script_witness: keypair.value.data}
  end
end
