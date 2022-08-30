defmodule BitcoinLib.Transaction.Output do
  defstruct [:value, :script_pub_key]

  @moduledoc """
  Based on https://learnmeabitcoin.com/technical/output
  """

  alias BitcoinLib.Signing.Psbt.CompactInteger
  alias BitcoinLib.Transaction.Output
  alias BitcoinLib.Script

  @byte 8

  def extract_from(<<value::little-64, remaining::bitstring>>) do
    case extract_script_pub_key(remaining) do
      {:ok, script_pub_key, remaining} ->
        output = %Output{value: value, script_pub_key: script_pub_key}
        {output, remaining}

      {:error, message} ->
        {%{error: message}, remaining}
    end
  end

  @doc """
  Encodes an output into a bitstring

  ## Examples

    iex> %BitcoinLib.Transaction.Output{
    ...>   script_pub_key: [
    ...>     %BitcoinLib.Script.Opcodes.Stack.Dup{},
    ...>     %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
    ...>     %BitcoinLib.Script.Opcodes.Data{value: <<0xf86f0bc0a2232970ccdf4569815db500f1268361::160>>},
    ...>     %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
    ...>     %BitcoinLib.Script.Opcodes.Crypto.CheckSig{}
    ...>   ],
    ...>   value: 129000000
    ...> } |> BitcoinLib.Transaction.Output.encode
    <<0x4062b00700000000::64>> <> # value
    <<0x19::8>>                       <> # script_pub_key size
    <<0x76a914f86f0bc0a2232970ccdf4569815db500f126836188ac::200>> # script_pub_key
  """
  def encode(%Output{} = output) do
    {script_pub_key_size, script_pub_key} =
      output.script_pub_key
      |> Script.encode()

    <<output.value::little-64, script_pub_key_size::bitstring, script_pub_key::bitstring>>
  end

  defp extract_script_pub_key(remaining) do
    %CompactInteger{value: script_pub_key_size, remaining: remaining} =
      CompactInteger.extract_from(remaining)

    case script_pub_key_size <= byte_size(remaining) do
      true ->
        script_pub_key_bit_size = script_pub_key_size * @byte

        <<script_pub_key::bitstring-size(script_pub_key_bit_size), remaining::bitstring>> =
          remaining

        ##### TODO: Script.parse() should be able to return a parsing error
        script_pub_key =
          script_pub_key
          |> Script.parse()

        {:ok, script_pub_key, remaining}

      false ->
        {:error, "badly formatted script pub key"}
    end
  end
end
