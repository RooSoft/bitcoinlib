defmodule BitcoinLib.Script.Types.P2sh do
  @moduledoc """
  P2SH helper that can issue scripts out of simple parameters
  """
  alias BitcoinLib.Script.Opcodes

  @doc """
  Returns a full P2SH script out of a public key hash

  ## Examples
    iex> <<0x11c371a2b2d22c7b8b1b51d9fde0e44a9dfdc7bb::160>>
    ...> |> BitcoinLib.Script.Types.P2sh.create()
    [
      %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
      %BitcoinLib.Script.Opcodes.Data{value: <<0x11c371a2b2d22c7b8b1b51d9fde0e44a9dfdc7bb::160>>},
      %BitcoinLib.Script.Opcodes.BitwiseLogic.Equal{}
    ]
  """
  @spec create(bitstring()) :: list()
  def create(script_hash) do
    [
      %Opcodes.Crypto.Hash160{},
      %Opcodes.Data{value: script_hash},
      %Opcodes.BitwiseLogic.Equal{}
    ]
  end
end
