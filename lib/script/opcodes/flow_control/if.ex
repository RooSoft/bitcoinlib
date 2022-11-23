defmodule BitcoinLib.Script.Opcodes.FlowControl.If do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_IF
  Opcode 99
  Hex 0x63
  <expression> if [statements] [else [statements]]* endif
  If the top stack value is not False, the statements are executed. The top stack value is removed.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  @value 0x63

  @doc """
  Returns 0x63

  ## Examples
      iex> BitcoinLib.Script.Opcodes.FlowControl.If.v()
      0x63
  """
  @spec v() :: 0x63
  def v do
    @value
  end

  @doc """
  Returns <<0x63>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.FlowControl.If.encode()
      <<0x63>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  If the top stack value is not False, the statements are executed. The top stack value is removed.
  """
  def execute(_opcode, [_first_element | _remaining]) do
    {:error, "OP_IF execution has not been implemented yet"}
  end
end
