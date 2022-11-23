defmodule BitcoinLib.Script.Opcodes.Crypto.CodeSeparator do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_CODESEPARATOR
  Opcode 171
  Hex 0xab
  Input nothing
  Output nothing
  All of the signature checking words will only match signatures to the data after
  the most recently-executed OP_CODESEPARATOR.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  @value 0xAB

  @doc """
  Returns 0xab

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.CodeSeparator.v()
      0xab
  """
  @spec v() :: 0xAB
  def v do
    @value
  end

  @doc """
  Returns <<0xab>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.CodeSeparator.encode()
      <<0xab>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  All of the signature checking words will only match signatures to the data after
  the most recently-executed OP_CODESEPARATOR.
  """
  def execute(_opcode, _remaining) do
    {:error, "OP_CODESEPARATOR execution has not been implemented yet"}
  end
end
