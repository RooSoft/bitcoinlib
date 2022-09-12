defmodule BitcoinLib.Script.Opcodes.Crypto.CheckSig do
  @moduledoc """
  Based on https://en.bitcoin.it/wiki/Script

  Word OP_CHECKSIG
  Opcode 172
  Hex 0xac
  Input sig pubkey
  Output True / false
  Description
    The entire transaction's outputs, inputs, and script (from the most recently-executed
    OP_CODESEPARATOR to the end) are hashed. The signature used by OP_CHECKSIG must be a
    valid signature for this hash and public key. If it is, 1 is returned, 0 otherwise.
  """

  @behaviour BitcoinLib.Script.Opcode

  defstruct [:script]

  alias BitcoinLib.Crypto.Secp256k1
  alias BitcoinLib.Script.Opcodes.Crypto.CheckSig
  alias BitcoinLib.Key.PublicKey

  @value 0xAC

  def v do
    @value
  end

  def encode() do
    <<@value::8>>
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
  alias BitcoinLib.Script.Opcodes.Crypto.CheckSig
  alias BitcoinLib.Formatting.HexBinary

  def inspect(%CheckSig{script: nil}, _opts) do
    "%BitcoinLib.Script.Opcodes.Crypto.CheckSig{}"
  end

  def inspect(%CheckSig{} = check_sig, _opts) do
    %CheckSig{script: script} = check_sig

    hex_binary = %HexBinary{data: script}

    "%BitcoinLib.Script.Opcodes.Crypto.CheckSig{script: #{inspect(hex_binary)}}"
  end
end
