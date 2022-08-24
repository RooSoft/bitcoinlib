defmodule BitcoinLib.Script.Opcodes.Crypto.CheckSig do
  @behaviour BitcoinLib.Script.Opcode

  defstruct [:script]

  alias BitcoinLib.Crypto.Secp256k1
  alias BitcoinLib.Script.Opcodes.Crypto.CheckSig
  alias BitcoinLib.Key.PublicKey

  @value 0xAC

  def v do
    @value
  end

  @spec execute(%CheckSig{}, list()) :: {:ok, list()}
  def execute(%CheckSig{script: script}, [sig_pub_key | [sig | remaining]]) do
    script_hex = script |> Binary.to_hex()

    case Secp256k1.validate(sig, script_hex, %PublicKey{key: sig_pub_key}) do
      true -> {:ok, [1 | remaining]}
      false -> {:ok, [0 | remaining]}
    end
  end
end

defimpl Inspect, for: BitcoinLib.Script.Opcodes.Crypto.CheckSig do
  @byte 8

  alias BitcoinLib.Script.Opcodes.Crypto.CheckSig

  def inspect(%CheckSig{script: script}, _opts) do
    hex_script = Base.encode16(script.value, case: :lower)
    script_size = byte_size(script.value) * @byte

    "%BitcoinLib.Script.Opcodes.Data{value: <<0x#{hex_script}::#{script_size}>>}"
  end
end
