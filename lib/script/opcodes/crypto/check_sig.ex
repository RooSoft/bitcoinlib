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

  @type t :: CheckSig

  @value 0xAC

  @doc """
  Returns 0xac

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.CheckSig.v()
      0xac
  """
  @spec v() :: 0xAC
  def v do
    @value
  end

  @doc """
  Returns <<0xac>>

  ## Examples
      iex> BitcoinLib.Script.Opcodes.Crypto.CheckSig.encode()
      <<0xac>>
  """
  @spec encode() :: <<_::8>>
  def encode() do
    <<@value::8>>
  end

  @doc """
  The entire transaction's outputs, inputs, and script (from the most recently-executed
  OP_CODESEPARATOR to the end) are hashed. The signature used by OP_CHECKSIG must be a
  valid signature for this hash and public key. If it is, 1 is returned, 0 otherwise.

  ## Examples
      iex> sig_pub_key = <<0x0218fb7aff2c6cb9c25b7cd9aa0b9bdd712e5617f07cb0c96bdda0b44c25a5d25f::264>>
      ...> signature = <<0x304402202911998439e90fc7c3e12c8fd9e5b65d451c3e157fdfdf0991281fb90038eaf20220623615e5e4a768edc19fd480ac67b7f39d46689fdbfb54ffa49145117d17aa71::560>>
      ...> %BitcoinLib.Script.Opcodes.Crypto.CheckSig{
      ...>   script: <<0x76a91417cdc02e31846f9e7c25952700f53e9752a0a3c288ac::200>>
      ...> }
      ...> |> BitcoinLib.Script.Opcodes.Crypto.CheckSig.execute([sig_pub_key, signature, 3])
      {:ok, [1, 3]}
  """
  @spec execute(CheckSig.t(), list()) :: {:ok, list()}
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
