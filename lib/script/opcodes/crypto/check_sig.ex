defmodule BitcoinLib.Script.Opcodes.Crypto.CheckSig do
  @behaviour BitcoinLib.Script.Opcode

  defstruct type: BitcoinLib.Script.Opcodes.Crypto.CheckSig

  @value 0xAC

  def v do
    @value
  end

  def execute([sig_pub_key | [sig | remaining]]) do
 #   IO.inspect(sig_pub_key, label: "SIG PUB KEY")
 #   IO.inspect(sig, label: "SIG")

    {:ok, [1 | remaining]}
  end
end
