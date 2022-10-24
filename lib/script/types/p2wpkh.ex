defmodule BitcoinLib.Script.Types.P2wpkh do
  @moduledoc """
  P2WPKH helper that can issue scripts out of simple parameters
  """
  alias BitcoinLib.Script.Opcodes

  @doc """
  Returns a full P2WPKH script out of a public key hash

  ## Examples
    iex> <<0x11c371a2b2d22c7b8b1b51d9fde0e44a9dfdc7bb::160>>
    ...> |> BitcoinLib.Script.Types.P2wpkh.create()
    [
      %BitcoinLib.Script.Opcodes.Constants.Zero{},
      %BitcoinLib.Script.Opcodes.Data{value: <<0x11c371a2b2d22c7b8b1b51d9fde0e44a9dfdc7bb::160>>}
    ]
  """
  @spec create(bitstring()) :: list()
  def create(public_key_hash) do
    [
      %Opcodes.Constants.Zero{},
      %Opcodes.Data{value: public_key_hash}
    ]
  end
end
