defmodule BitcoinLib.Script.Types.P2pkh do
  @moduledoc """
  P2PKH helper that can issue scripts out of simple parameters
  """
  alias BitcoinLib.Script.Opcodes

  @doc """
  Returns a full P2PKH script out of a public key hash

  ## Examples
      iex> <<0xafc3e518577316386188af748a816cd14ce333f2::160>>
      ...> |> BitcoinLib.Script.Types.P2pkh.create()
      [
        %BitcoinLib.Script.Opcodes.Stack.Dup{},
        %BitcoinLib.Script.Opcodes.Crypto.Hash160{},
        %BitcoinLib.Script.Opcodes.Data{value: <<0xafc3e518577316386188af748a816cd14ce333f2::160>>},
        %BitcoinLib.Script.Opcodes.BitwiseLogic.EqualVerify{},
        %BitcoinLib.Script.Opcodes.Crypto.CheckSig{}
      ]
  """
  @spec create(bitstring()) :: list()
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
