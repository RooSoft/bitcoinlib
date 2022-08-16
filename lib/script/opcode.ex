defmodule BitcoinLib.Script.Opcode do
  @moduledoc """
  Opcode behaviour, allowing execution and returning the opcode's integer value
  """

  @doc """
  Returns the opcode's value
  """
  @callback v() :: byte()

  @doc """
  Attemps to execute the opcode against the stack given as an argument,
  returning either the altered stack or an error
  """
  @callback execute(any(), list()) :: {:ok, list()} | {:error, binary()}
end
