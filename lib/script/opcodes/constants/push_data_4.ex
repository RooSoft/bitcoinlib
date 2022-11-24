defmodule BitcoinLib.Script.Opcodes.Constants.PushData4 do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_PUSHDATA4
  Opcode 78
  Hex 0x4e
  Input (special)
  Output data
  The next four bytes contain the number of bytes to be pushed onto the stack in little endian order.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct [:value]

  @value 0x4e

  @doc """
  Returns 0x4e

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.PushData4.v()
      0x4e
  """
  @spec v() :: 0x4e
  def v do
    @value
  end

  @doc """
  Returns <<>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.PushData4.encode()
      <<0x4e>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  def execute(_opcode, [_first_element | _remaining]) do
    {:error, "OP_PUSHDATA4 execution has not been implemented yet"}
  end
end
