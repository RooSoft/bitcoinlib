defmodule BitcoinLib.Script.Types.P2sh do
  @moduledoc """
  P2SH helper that can issue scripts out of simple parameters
  """
  alias BitcoinLib.Script.Opcodes

  @doc """
  Returns a full P2SH script out of a public key hash
  """
  def create(script_hash) do
    [
      %Opcodes.Crypto.Hash160{},
      %Opcodes.Data{value: script_hash},
      %Opcodes.BitwiseLogic.Equal{}
    ]
  end
end
