defmodule BitcoinLib.Script.Opcodes.Locktime.CheckLockTimeVerify do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script#Locktime

  Word OP_CHECKLOCKTIMEVERIFY
  Opcode 177
  Hex 0xb1
  Input x
  Output x / fail
  Marks transaction as invalid if the top stack item is greater than the transaction's
  nLockTime field, otherwise script evaluation continues as though an OP_NOP was executed.
  Transaction is also invalid if any of these is true:
  1. the stack is empty
  2. the top stack item is negative
  3. the top stack item is greater than or equal to 500000000 while the
     transaction's nLockTime field is less than 500000000, or vice versa
  4. the input's nSequence field is equal to 0xffffffff. The precise semantics
     are described in BIP 0065.
  """

  @behaviour BitcoinLib.Script.Opcode

  alias BitcoinLib.Script.Opcodes.Locktime.CheckLockTimeVerify

  defstruct []

  @value 0xB1

  @doc """
  Returns 0xb1

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Locktime.CheckLockTimeVerify.v()
      0xb1
  """
  @spec v() :: 0xB1
  def v do
    @value
  end

  @doc """
  Returns <<0xb1>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Locktime.CheckLockTimeVerify.encode()
      <<0xb1>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  Returns 1 if the inputs are exactly equal, 0 otherwise.

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Locktime.CheckLockTimeVerify.execute(
      ...>   %BitcoinLib.Script.Opcodes.Locktime.CheckLockTimeVerify{},
      ...>   [3, 4]
      ...> )
      {:error, "OP_CHECKLOCKTIMEVERIFY execution has not been implemented yet"}
  """
  @spec execute(%CheckLockTimeVerify{}, list()) ::
          {:ok, [1 | list()]} | {:ok, [0 | list()]} | {:error, binary()}
  def execute(_opcode, []),
    do: {:error, "trying to execute OP_CHECKLOCKTIMEVERIFY on an empty stack"}

  def execute(_opcode, [_first_element | _remaining]) do
    {:error, "OP_CHECKLOCKTIMEVERIFY execution has not been implemented yet"}
  end
end
