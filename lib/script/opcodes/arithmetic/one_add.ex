defmodule BitcoinLib.Script.Opcodes.Arithmetic.OneAdd do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_1ADD
  Opcode 139
  Hex 0x8b
  Input in
  Output out
  1 is added to the input.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Arithmetic.OneAdd

  @type t :: OneAdd

  @value 0x8B

  @doc """
  Returns 0x8b

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.OneAdd.v()
      0x8b
  """
  @spec v() :: 0x8B
  def v do
    @value
  end

  @doc """
  Returns <<0x8b>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.OneAdd.encode()
      <<0x8b>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  b is subtracted from a.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.OneAdd.execute(
      ...>  %BitcoinLib.Script.Opcodes.Arithmetic.OneAdd{},
      ...>  [7, 3, 1]
      ...> )
      {:ok, [8, 3, 1]}
  """
  @spec execute(OneAdd.t(), list()) :: {:ok, list()}
  def execute(%OneAdd{}, [first] ++ remaining) do
    {:ok, [first + 1 | remaining]}
  end
end
