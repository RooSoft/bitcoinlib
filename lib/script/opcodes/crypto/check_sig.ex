defmodule BitcoinLib.Script.Opcodes.Crypto.CheckSig do
  defstruct []

  @value 0xAC

  def v do
    @value
  end
end
