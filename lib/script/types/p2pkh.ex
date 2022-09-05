defmodule BitcoinLib.Script.Types.P2pkh do
  @moduledoc """
  P2PKH helper that can issue scripts out of simple parameters
  """
  alias BitcoinLib.Script.Opcodes

  @doc """
  Returns a full P2PKH script out of a public key hash
  """
  def create(target_public_key_hash) do
    [
      %Opcodes.Stack.Dup{},
      %Opcodes.Crypto.Hash160{},
      %Opcodes.Data{value: target_public_key_hash},
      %Opcodes.BitwiseLogic.EqualVerify{},
      %Opcodes.Crypto.CheckSig{}
    ]
  end
end
