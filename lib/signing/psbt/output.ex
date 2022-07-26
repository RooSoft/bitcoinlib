defmodule BitcoinLib.Signing.Psbt.Output do
  defstruct unknowns: []

  alias BitcoinLib.Signing.Psbt.{Keypair, KeypairList, Output}

  def from_keypair_list(%KeypairList{} = keypair_list) do
    keypair_list.keypairs
    |> Enum.reduce(%Output{}, &dispatch_keypair/2)
  end

  defp dispatch_keypair(%Keypair{key: key, value: value}, output) do
    case key.type do
      _ -> add_unknown(output, key, value)
    end
  end

  defp add_unknown(input, key, value) do
    input
    |> Map.put(:unknowns, [{key, value} | input.unknowns])
  end
end
