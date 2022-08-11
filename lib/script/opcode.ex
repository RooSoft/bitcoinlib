defmodule BitcoinLib.Script.Opcode do
  @doc """
  Returns the opcode's value
  """
  @callback v() :: String.t()

  @doc """
  Attemps to execute the opcode against the stack given as an argument,
  returning either the altered stack or an error
  """
  @callback execute(bitstring()) :: {:ok, list()} | {:error, binary()}
end
