defmodule BitcoinLib.Signing.Psbt.Global do
  defstruct []

  alias BitcoinLib.Signing.Psbt.{CompactInteger, Global}

  def from_data(_data) do
  #  data
  #  |> extract_keypairs()
  #  |> IO.inspect()

    %Global{}
  end

  # defp extract_keypairs(data) do
  #   extract_keypairs([], data)
  # end

  # defp extract_keypairs(keypairs, <<0::8, remaining::binary>>), do: {keypairs, remaining}

  # defp extract_keypairs(keypairs, <<length::8, data::binary>>) do
  #   {key, data} = extract_key(data)
  #   {value, data} = extract_value(data)

  #   {keytype, data} = extract_keytype(data)

  #   data_length =


  #   extract_keypairs([key | keypairs], data)
  # end

  # defp extract_key(data) do

  # end

  # defp extract_key(data), do: CompactInteger.extract_from(data)
  # defp extract_keytype(data), do: CompactInteger.extract_from(data)
end
