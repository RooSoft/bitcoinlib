defmodule BitcoinLib.Signing.Psbt.Keypair.Value do
  @moduledoc """
  Extracts a keypair's value from a binary according to the
  [specification](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki#specification)

  <value> := <valuelen> <valuedata>
  """
  defstruct [:length, :data]

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Signing.Psbt.Keypair.Value

  @doc """
  Extracts a value from some arbitrary data, returning a tuple containing the value and the remaining data
  """
  @spec extract_from(binary()) :: {%Value{}, binary}
  def extract_from(data) do
    extracted =
      %{value: %Value{}, data: data}
      |> extract_valuelen()
      |> extract_valuedata()

    {extracted.value, extracted.data}
  end

  defp extract_valuelen(%{data: data} = map) do
    %{value: valuelen, remaining: data} = CompactInteger.extract_from(data)

    value = %Value{length: valuelen}

    %{map | value: value, data: data}
  end

  defp extract_valuedata(%{value: value, data: data} = map) do
    value_length = value.length

    <<value_data::binary-size(value_length), data::bitstring>> = data

    value =
      value
      |> Map.put(:data, value_data)

    %{map | value: value, data: data}
  end
end
