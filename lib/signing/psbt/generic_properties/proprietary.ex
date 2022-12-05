defmodule BitcoinLib.Signing.Psbt.GenericProperties.Proprietary do
  @moduledoc """
  A list of proprietary properties in a partially signed bitcoin transaction
  """

  defstruct [:key_identifier, :key_data, :data]

  alias BitcoinLib.Signing.Psbt.{CompactInteger, Keypair}
  alias BitcoinLib.Signing.Psbt.GenericProperties.Proprietary

  alias BitcoinLib.Signing.Psbt.GenericProperties.Proprietary

  @type t :: Proprietary

  # TODO: document
  @spec parse(Keypair.t()) :: Proprietary.t()
  def parse(%Keypair{key: key, value: value}) do
    %{identifier: key_identifier, key_data: key_data, data: data} =
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
    %CompactInteger{value: key_data_size, remaining: remaining} =
      key
      |> CompactInteger.extract_from()

    <<key_data::size(key_data_size), remaining::bitstring>> = remaining

    %{map | key: remaining}
    |> Map.put(:key_data, key_data)
  end

  defp parse_data(%{value: value} = map) do
    <<data::binary>> = value

    %{map | value: ""}
    |> Map.put(:data, data)
  end
end
