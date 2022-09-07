defmodule BitcoinLib.Signing.Psbt.GenericProperties.Proprietary do
  defstruct [:key_identifier, :key_data, :data]

  alias BitcoinLib.Signing.Psbt.{CompactInteger, Keypair}
  alias BitcoinLib.Signing.Psbt.GenericProperties.Proprietary

  @spec parse(%Keypair{}) :: %Proprietary{}
  def parse(%Keypair{key: key, value: value}) do
    %{key_identifier: key_identifier, key_data: key_data, data: data} =
      %{key: key, value: value}
      |> parse_key_identifier
      |> parse_key_data
      |> parse_data

    %Proprietary{key_identifier: key_identifier, key_data: key_data, data: data}
  end

  defp parse_key_identifier(%{key: key} = map) do
    %CompactInteger{value: identifier_size, remaining: remaining} =
      key
      |> CompactInteger.extract_from()

    <<identifier::size(identifier_size), remaining::bitstring>> = remaining

    %{map | key: remaining}
    |> Map.put(:identifier, identifier)
  end

  defp parse_key_data(%{key: key} = map) do
    %CompactInteger{value: data_size, remaining: remaining} =
      key
      |> CompactInteger.extract_from()

    <<identifier::size(data_size), remaining::bitstring>> = remaining

    %{map | key: remaining}
    |> Map.put(:identifier, identifier)
  end

  defp parse_data(%{value: value} = map) do
    <<data::binary>> = value

    %{map | value: ""}
    |> Map.put(:data, data)
  end
end
