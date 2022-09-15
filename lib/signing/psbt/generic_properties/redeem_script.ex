defmodule BitcoinLib.Signing.Psbt.GenericProperties.RedeemScript do
  defstruct [:script]

  alias BitcoinLib.Signing.Psbt.GenericProperties.RedeemScript
  alias BitcoinLib.Signing.Psbt.Keypair
  alias BitcoinLib.Signing.Psbt.Keypair.{Key}
  alias BitcoinLib.Script

  @spec parse(%Keypair{}) :: {:ok, %RedeemScript{}} | {:error, binary()}
  def parse(keypair) do
    %{keypair: keypair}
    |> validate_keypair()
    |> extract_redeem_script()
    |> create_output()
  end

  defp create_output(%{error: message}), do: {:error, message}
  defp create_output(%{redeem_script: redeem_script}), do: {:ok, redeem_script}

  defp validate_keypair(%{keypair: keypair} = map) do
    case keypair.key do
      %Key{data: <<>>} ->
        map

      _ ->
        Map.put(map, :error, "invalid redeemscript typed key")
    end
  end

  defp extract_redeem_script(%{error: _message} = map),
    do: map

  defp extract_redeem_script(%{keypair: keypair} = map) do
    ## TODO: Properly manage script errors
    case Script.parse(keypair.value.data) do
      {:ok, script} ->
        Map.put(map, :redeem_script, %RedeemScript{script: script})

      {:error, message} ->
        Map.put(map, :error, message)
    end
  end
end
