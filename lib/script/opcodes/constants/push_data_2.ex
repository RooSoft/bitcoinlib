defmodule BitcoinLib.Script.Opcodes.Constants.PushData2 do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_PUSHDATA2
  Opcode 77
  Hex 0x4d
  Input (special)
  Output data
  The next two bytes contain the number of bytes to be pushed onto the stack in little endian order.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct [:value]

  @value 0x4D

  @doc """
  Returns 0x4d

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.PushData2.v()
      0x4d
  """
  @spec v() :: 0x4D
  def v do
    @value
  end

  @doc """
  Returns <<>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.PushData2.encode()
      <<0x4d>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  def execute(_opcode, [_first_element | _remaining]) do
    {:error, "OP_PUSHDATA2 execution has not been implemented yet"}
  end
end
