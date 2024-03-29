defmodule BitcoinLib.Crypto.Bitstring do
  @moduledoc """
  Bitstring manipulation functions
  """

  @doc """
  Takes any bistring and returns bytes in the reverse order, such as going from
  little endian to big endian or the opposite

  ## Possible improvement

  Found out that this code would also work, might have to test for performance

  ```elixir
    <<0xb62e9d36389427d39e5d438a05045c23d1938e4242661c5fe2ad87c46337b091::256>>
    |> :binary.decode_unsigned(:big) # could omit :big since it's default
    |> :binary.encode_unsigned(:little)
    <<0x91b03763c487ade25f1c6642428e93d1235c04058a435d9ed3279438369d2eb6::256>>
  ```

  ## Examples
      iex> <<0xb62e9d36389427d39e5d438a05045c23d1938e4242661c5fe2ad87c46337b091::256>>
      ...> |> BitcoinLib.Crypto.Bitstring.reverse()
      <<0x91b03763c487ade25f1c6642428e93d1235c04058a435d9ed3279438369d2eb6::256>>
  """
  @spec reverse(bitstring()) :: bitstring()
  def reverse(bitstring) do
    bitstring
    |> :binary.bin_to_list()
    |> Enum.reverse()
    |> :binary.list_to_bin()
  end
end
