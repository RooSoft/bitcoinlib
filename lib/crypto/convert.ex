defmodule BitcoinLib.Crypto.Convert do
  def integer_to_binary(value, bytes_length \\ 32) do
    value
    |> Binary.from_integer()
    |> Binary.pad_leading(bytes_length)
  end
end
