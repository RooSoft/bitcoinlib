defmodule BitcoinLib.Script.Opcodes.Data do
  defstruct [:value]

  alias BitcoinLib.Script.Opcodes.Data

  def encode(%Data{value: value}) do
    size_of_value = byte_size(value)

    <<size_of_value::8, value::bitstring>>
  end
end

defimpl Inspect, for: BitcoinLib.Script.Opcodes.Data do
  @byte 8

  def inspect(data, _opts) do
    hex_data = Base.encode16(data.value, case: :lower)
    data_size = byte_size(data.value) * @byte

    "%BitcoinLib.Script.Opcodes.Data{value: <<0x#{hex_data}::#{data_size}>>}"
  end
end
