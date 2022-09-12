defmodule BitcoinLib.Script.Opcodes.Data do
  @moduledoc """
  Adds between 1 and 75 bytes of data into the stack
  """
  defstruct [:value]

  alias BitcoinLib.Script.Opcodes.Data

  @doc """
  Adds between 1 and 75 bytes of data into the stack

  ## Examples
    iex> %BitcoinLib.Script.Opcodes.Data{value: <<1, 2, 3, 4, 5>>}
    ...> |> BitcoinLib.Script.Opcodes.Data.encode()
    <<5, 1, 2, 3, 4, 5>>
  """
  @spec encode(%Data{}) :: bitstring()
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
