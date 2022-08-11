defmodule BitcoinLib.Script.Opcodes.Stack.Dup do
  defstruct []

  @value 0x76

  def v do
    @value
  end
end
