defmodule BitcoinLib.Signing.Psbt.Global.Proprietary do
  defstruct [:identifier, :data]

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Signing.Psbt.Global.Proprietary

  def parse(remaining) do
    %{identifier: identifier, data: data} =
      %{remaining: remaining}
      |> parse_identifier
      |> parse_data

    %Proprietary{identifier: identifier, data: data}
  end

  defp parse_identifier(%{remaining: remaining} = map) do
    %CompactInteger{value: identifier_size, remaining: remaining} =
      remaining
      |> CompactInteger.extract_from()

    <<identifier::size(identifier_size), remaining::bitstring>> = remaining

    %{map | remaining: remaining}
    |> Map.put(:identifier, identifier)
  end

  defp parse_data(%{remaining: remaining} = map) do
    %CompactInteger{value: data_size, remaining: remaining} =
      remaining
      |> CompactInteger.extract_from()

    <<identifier::size(data_size), remaining::bitstring>> = remaining

    %{map | remaining: remaining}
    |> Map.put(:identifier, identifier)
  end
end
