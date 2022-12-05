defmodule BitcoinLib.Script.Opcodes.Arithmetic.Min do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_MIN
  Opcode 163
  Hex 0xa3
  Input a b
  Output out
  Returns the smaller of a and b.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.Arithmetic.Min

  @type t :: Min

  @value 0xA3

  @doc """
  Returns 0xa3

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Min.v()
      0xa3
  """
  @spec v() :: 0xA3
  def v do
    @value
  end

  @doc """
  Returns <<0xa3>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Min.encode()
      <<0xa3>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  Returns the smaller of a and b.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Arithmetic.Min.execute(
      ...>  %BitcoinLib.Script.Opcodes.Arithmetic.Min{},
      ...>  [2, 3, 1]
      ...> )
      {:ok, [2, 1]}
  """
  @spec execute(Min.t(), list()) :: {:ok, list()}
  def execute(%Min{}, [first, second] ++ remaining) do
    min = Enum.min([first, second])

    {:ok, [min] ++ remaining}
  end
end
