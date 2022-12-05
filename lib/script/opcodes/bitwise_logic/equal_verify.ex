defmodule BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script#Bitwise_logic

  Word OP_EQUALVERIFY
  Opcode 136
  Hex 0x88
  Input x1 x2
  Output Nothing / fail
  Description Same as OP_EQUAL, but runs OP_VERIFY afterward.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Opcodes.BitwiseLogic.{Equal, EqualVerify}
  alias BitcoinLib.Script.Opcodes.FlowControl.Verify

  @type t :: EqualVerify

  @value 0x88

  @doc """
  Returns 0x88

  ## Examples
      iex> BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify.v()
      0x88
  """
  @spec v() :: 0x88
  def v do
    @value
  end

  @doc """
  Returns <<0x88>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify.encode()
      <<0x88>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  Returns 1 if the inputs are exactly equal, 0 otherwise, and runs OP_VERIFY afterward.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify.execute(0x88, [3, 3, 4])
      {:ok, [4]}
  """
  @spec execute(EqualVerify.t(), list()) :: {:ok, list()} | {:error, binary()}
  def execute(_opcode, []), do: {:error, "trying to execute OP_EQUAL_VERIFY on an empty stack"}

  def execute(_opcode, [element | []]),
    do: {:error, "trying to execute OP_EQUAL_VERIFY on a stack with a single element #{element}"}

  def execute(_opcode, [_first_element | [_second_element | _]] = stack) do
    case Equal.execute(%Equal{}, stack) do
      {:ok, stack} -> Verify.execute(%Verify{}, stack)
      {:error, message} -> {:error, message}
    end
  end
end
