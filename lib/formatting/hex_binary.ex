defmodule BitcoinLib.Formatting.HexBinary do
  defstruct [:data]
end

defimpl Inspect, for: BitcoinLib.Formatting.HexBinary do
  @byte 8

  def inspect(%BitcoinLib.Formatting.HexBinary{} = binary, _opts) do
    print_compact_bitstring(binary.data)
  end

  defp print_compact_bitstring(bitstring) do
    hex_data = Base.encode16(bitstring, case: :lower)
    data_size = byte_size(bitstring) * @byte

    "<<0x#{hex_data}::#{data_size}>>"
  end
end
