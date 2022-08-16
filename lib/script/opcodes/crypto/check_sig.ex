defmodule BitcoinLib.Script.Opcodes.Crypto.CheckSig do
  @behaviour BitcoinLib.Script.Opcode

  defstruct [:script, type: BitcoinLib.Script.Opcodes.Crypto.CheckSig]

  alias BitcoinLib.Crypto.Secp256k1
  alias BitcoinLib.Script.Opcodes.Crypto.CheckSig

  @value 0xAC

  def v do
    @value
  end

  def execute(%CheckSig{script: script}, [sig_pub_key | [sig | remaining]]) do
    script_hex = script |> Binary.to_hex()

    case Secp256k1.validate(sig, script_hex, sig_pub_key) do
      true -> {:ok, [1 | remaining]}
      false -> {:ok, [0 | remaining]}
    end
  end
end
