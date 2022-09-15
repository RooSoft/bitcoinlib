defmodule BitcoinLib.Signing.Psbt.GenericProperties.RedeemScript do
  defstruct [:script]

  alias BitcoinLib.Signing.Psbt.GenericProperties.RedeemScript
  alias BitcoinLib.Signing.Psbt.Keypair.{Key}
  alias BitcoinLib.Script

  def parse(keypair) do
    %{keypair: keypair, redeem_script: %RedeemScript{}}
    |> validate_keypair()
    |> extract_redeem_script()
  end

  defp validate_keypair(%{keypair: keypair, redeem_script: redeem_script} = map) do
    case keypair.key do
      %Key{data: <<>>} ->
        map

      _ ->
        %{map | redeem_script: Map.put(redeem_script, :error, "invalid redeemscript typed key")}
    end
  end

  defp extract_redeem_script(%{redeem_script: %{error: _message} = redeem_script}),
    do: redeem_script

  defp extract_redeem_script(%{keypair: keypair}) do
    ## TODO: Properly manage script errors
    script =
      keypair.value.data
      |> Script.parse!()

    %RedeemScript{script: script}
  end
end
