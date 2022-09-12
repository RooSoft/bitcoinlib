defmodule BitcoinLib.Script.Opcodes.FlowControl.Verify do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_VERIFY
  Opcode 105
  Hex 0x69
  Input True / false
  Output Nothing / fail
  Description Marks transaction as invalid if top stack value is not true. The top stack value is removed.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct []

  alias BitcoinLib.Script.Value

  @value 0x69

  def v do
    @value
  end

  def execute(_opcode, []), do: {:error, "trying to execute OP_VERIFY on an empty stack"}

  def execute(_opcode, [first_element | remaining]) do
    case Value.is_true?(first_element) do
      true ->
        {:ok, remaining}

      false ->
        {:error,
         "the script is invalid, it doesn't pass the OP_VERIFY test with #{first_element} as the top stack value"}
    end
  end
end
