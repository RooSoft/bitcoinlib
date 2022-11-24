defmodule BitcoinLib.Script.Opcodes.FlowControl.Else do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_IF
  Opcode 103
  Hex 0x67
  <expression> if [statements] [else [statements]]* endif
  If the preceding OP_IF or OP_NOTIF or OP_ELSE was not executed then
  these statements are and if the preceding OP_IF or OP_NOTIF or OP_ELSE
  was executed then these statements are not.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  @value 0x67

  @doc """
  Returns 0x67

  ## Examples
      iex> BitcoinLib.Script.Opcodes.FlowControl.Else.v()
      0x67
  """
  @spec v() :: 0x67
  def v do
    @value
  end

  @doc """
  Returns <<0x67>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.FlowControl.Else.encode()
      <<0x67>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  If the top stack value is not False, the statements are executed. The top stack value is removed.
  """
  def execute(_opcode, [_first_element | _remaining]) do
    {:error, "OP_ELSE execution has not been implemented yet"}
  end
end
