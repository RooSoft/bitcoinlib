defmodule BitcoinLib.Script.Opcodes.Constants.PushData1 do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_PUSHDATA1
  Opcode 76
  Hex 0x4c
  Input (special)
  Output data
  The next byte contains the number of bytes to be pushed onto the stack.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Constants.PushData1

  @value 0x4C

  @doc """
  Returns 0x4c

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.PushData1.v()
      0x4c
  """
  @spec v() :: 0x4C
  def v do
    @value
  end

  @doc """
  Returns <<>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.PushData1.encode()
      <<0x4c>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The next byte contains the number of bytes to be pushed onto the stack.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Constants.PushData1.execute(
      ...>  %BitcoinLib.Script.Opcodes.Constants.PushData1{},
      ...>  [<<3, 4, 2, 1>>, 3]
      ...> )
      {:ok, [<<4, 2, 1>>, 3]}
  """
  @spec execute(%PushData1{}, list()) :: {:ok, list()} | {:error, binary()}
  def execute(%PushData1{}, [<<count::8, data::bitstring>>, remaining]) do
    case byte_size(data) do
      ^count ->
        {:ok, [data, remaining]}

      data_size ->
        {:error, "trying to OP_PUSHDATA1 of size #{count}, but got #{data_size} bytes to store"}
    end

    {:ok, [data, remaining]}
  end
end
