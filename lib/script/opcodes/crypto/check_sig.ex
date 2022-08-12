defmodule BitcoinLib.Script.Opcodes.Crypto.CheckSig do
  @behaviour BitcoinLib.Script.Opcode

  defstruct type: BitcoinLib.Script.Opcodes.Crypto.CheckSig

  @value 0xAC

  def v do
    @value
  end

  def execute([_sig_pub_key | remaining]) do
    {:ok, [1 | remaining]}
  end
end
