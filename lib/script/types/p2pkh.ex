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
        %BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: <<0x76a914afc3e518577316386188af748a816cd14ce333f288ac::200>>}
      ]
  """
  @spec create(bitstring()) :: list()
  def create(target_public_key_hash) do
    script_prefix = <<0x76A914::24>>
    script_suffix = <<0x88AC::16>>

    script =
      <<script_prefix::bitstring, target_public_key_hash::bitstring, script_suffix::bitstring>>

    [
      %Opcodes.Stack.Dup{},
      %Opcodes.Crypto.Hash160{},
      %Opcodes.Data{value: target_public_key_hash},
      %Opcodes.BitwiseLogic.EqualVerify{},
      %Opcodes.Crypto.CheckSig{script: script}
    ]
  end
end
