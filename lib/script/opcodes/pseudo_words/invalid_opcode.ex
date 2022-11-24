defmodule BitcoinLib.Script.Opcodes.PseudoWords.InvalidOpcode do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_INVALIDOPCODE
  Opcode 255
  Hex 0xff
  Matches any opcode that is not yet assigned.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.PseudoWords.InvalidOpcode

  @value 0xFF

  @doc """
  Returns 0xff

  ## Examples
      iex> BitcoinLib.Script.Opcodes.PseudoWords.InvalidOpcode.v()
      0xff
  """
  @spec v() :: 0xFF
  def v do
    @value
  end

  @doc """
  Returns <<0xff>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.PseudoWords.InvalidOpcode.encode()
      <<0xff>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  Matches any opcode that is not yet assigned.

  Will fail by design.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.PseudoWords.InvalidOpcode.execute(
      ...>  %BitcoinLib.Script.Opcodes.PseudoWords.InvalidOpcode{},
      ...>  [3]
      ...> )
      {:error, "hit a OP_INVALIDOPCODE"}
  """
  def execute(%InvalidOpcode{}, _remaining) do
    {:error, "hit a OP_INVALIDOPCODE"}
  end
end
