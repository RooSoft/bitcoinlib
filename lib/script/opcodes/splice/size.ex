defmodule BitcoinLib.Script.Opcodes.Splice.Size do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_SIZE
  Opcode 130
  Hex 0x82
  Input nothing
  Output stack size
  Pushes the string length of the top element of the stack (without popping it).
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Splice.Size

  @type t :: Size

  @value 0x82

  @doc """
  Returns 0x82

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Splice.Size.v()
      0x82
  """
  @spec v() :: 0x82
  def v do
    @value
  end

  @doc """
  Returns <<0x82>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Splice.Size.encode()
      <<0x82>>
  """
  def encode() do
    <<@value::8>>
  end

  @doc """
  Pushes the string length of the top element of the stack (without popping it).

  ## Examples
      iex> stack = ["This is a test", 5]
      ...> %BitcoinLib.Script.Opcodes.Splice.Size{}
      ...> |> BitcoinLib.Script.Opcodes.Splice.Size.execute(stack)
      {:ok, [14, "This is a test", 5]}
  """
  @spec execute(Size.t(), list()) :: {:ok, list()} | {:error, binary()}

  def execute(_opcode, [string | remaining]) do
    size = byte_size(string)

    {:ok, [size, string] ++ remaining}
  end
end
