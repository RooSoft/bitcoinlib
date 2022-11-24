defmodule BitcoinLib.Script.Opcodes.FlowControl.EndIf do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_ENDIF
  Opcode 104
  Hex 0x68
  <expression> if [statements] [else [statements]]* endif
  Ends an if/else block. All blocks must end, or the transaction
  is invalid. An OP_ENDIF without OP_IF earlier is also invalid.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  @value 0x68

  @doc """
  Returns 0x68

  ## Examples
      iex> BitcoinLib.Script.Opcodes.FlowControl.EndIf.v()
      0x68
  """
  @spec v() :: 0x68
  def v do
    @value
  end

  @doc """
  Returns <<0x68>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.FlowControl.EndIf.encode()
      <<0x68>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  If the top stack value is not False, the statements are executed. The top stack value is removed.
  """
  def execute(_opcode, [_first_element | _remaining]) do
    {:error, "OP_ENDIF execution has not been implemented yet"}
  end
end
