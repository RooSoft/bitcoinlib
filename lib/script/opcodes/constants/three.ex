defmodule BitcoinLib.Script.Opcodes.Constants.Three do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_3
  Opcode 83
  Hex 0x53
  Input Nothing
  Output 3
  The number 3 is pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.Three

  @value 0x53

  @doc """
  Returns 0x53

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Three.v()
      0x53
  """
  @spec v() :: 0x53
  def v do
    @value
  end

  @doc """
  Returns <<0x53>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Three.encode()
      <<0x53>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The number 3 is pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.Three.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.Three{},
      ...>  [4]
      ...> )
      {:ok, [3, 4]}
  """
  def execute(%Three{}, remaining) do
    {:ok, [3 | remaining]}
  end
end
